// @vitest-environment node
import { describe, expect, it } from 'vitest';
import { calculateMetrics, comparablePeriods, type AccessFactInput, type MemberInput, type MetricsInput } from './index';
import { generate } from '../../../scripts/data/generator';
import golden from '../../../scripts/data/golden.json';

const member = (id = 'm', extra: Partial<MemberInput> = {}): MemberInput => ({ id, gym_unit_id: 'g',
  joined_at: '2020-01-01T00:00:00Z', deactivated_at: null, deleted_at: null, ...extra });
const access = (id: string, occurred_at: string, extra: Partial<AccessFactInput> = {}): AccessFactInput => ({
  id, occurred_at, gym_unit_id: 'g', member_id: 'm', status: 'VALID', ...extra });
const input = (extra: Partial<MetricsInput> = {}): MetricsInput => ({ gymUnit: { id: 'g', timezone: 'America/Sao_Paulo' },
  reference_instant: '2026-09-19T03:00:00Z', duration_days: 7, members: [member()], accesses: [], ...extra });

describe('deterministic metrics', () => {
  it('creates adjacent equal 7/30 day periods with an exclusive reference', () => {
    for (const days of [7, 30] as const) {
      const p = comparablePeriods('2026-09-19T00:00:00-03:00', days);
      expect(p.current.end).toBe('2026-09-19T03:00:00.000Z');
      expect(p.previous.end).toBe(p.current.start);
      expect(Date.parse(p.current.end) - Date.parse(p.current.start)).toBe(days * 86400000);
      expect(Date.parse(p.previous.end) - Date.parse(p.previous.start)).toBe(days * 86400000);
    }
  });
  it('counts [start,end), filters VOIDED, and groups by local date/weekday/hour', () => {
    const r = calculateMetrics(input({ accesses: [
      access('old', '2026-09-05T02:59:59Z'), access('previous', '2026-09-05T03:00:00Z'),
      access('before', '2026-09-12T02:59:59Z'), access('start', '2026-09-12T03:00:00Z'),
      access('local', '2026-09-19T02:59:59Z'), access('end', '2026-09-19T03:00:00Z'),
      access('future', '2026-09-20T03:00:00Z'), access('void', '2026-09-18T10:00:00Z', { status: 'VOIDED' }),
    ] }));
    expect(r.current.total_accesses).toBe(2);
    expect(r.previous.total_accesses).toBe(2);
    expect(r.current.daily_access_distribution).toHaveLength(7);
    expect(r.current.daily_access_distribution[6]).toEqual({ date: '2026-09-18', count: 1 });
    expect(r.current.weekday_distribution[5]).toBe(1);
    expect(r.current.hourly_access_distribution[23]).toBe(1);
    expect(r.current.hourly_access_distribution[0]).toBe(1);
    expect(r.member_frequency[0].last_visit_at).toBe('2026-09-19T03:00:00.000Z');
    expect(r.member_frequency[0].days_since_last_visit).toBe(0);
  });
  it('uses lifecycle snapshot, not current status or interval overlap', () => {
    const r = calculateMetrics(input({ members: [member('kept'),
      member('at-end', { deactivated_at: '2026-09-19T03:00:00Z' }),
      member('left', { deactivated_at: '2026-09-15T03:00:00Z' }),
      member('new', { joined_at: '2026-09-19T03:00:00Z' }),
      member('deleted', { deleted_at: '2026-09-20T03:00:00Z' }),
    ] }));
    expect(r.current.active_members).toBe(2);
    expect(r.previous.active_members).toBe(3);
  });
  it('returns null for zero baseline and zero active denominator, including empty history', () => {
    const empty = calculateMetrics(input({ members: [] }));
    expect(empty.attendance_change_percentage).toBeNull();
    expect(empty.current.average_visits_per_active_member).toBeNull();
    const r = calculateMetrics(input());
    expect(r.member_frequency[0]).toMatchObject({ last_visit_at: null, days_since_last_visit: null, member_frequency_change: null });
    expect(r.current.average_visits_per_active_member).toBe(0);
  });
  it('calculates decline, stability, new visits, absence and local calendar days without thresholds', () => {
    const rows = [access('a', '2026-09-06T10:00:00Z'), access('b', '2026-09-07T10:00:00Z'), access('c', '2026-09-18T23:30:00-03:00')];
    const r = calculateMetrics(input({ members: [member(), member('stable'), member('new'), member('absent')], accesses: [
      ...rows, access('d', '2026-09-06T10:00:00Z', { member_id: 'stable' }),
      access('e', '2026-09-13T10:00:00Z', { member_id: 'stable' }),
      access('f', '2026-09-13T10:00:00Z', { member_id: 'new' }),
      access('g', '2026-08-01T10:00:00Z', { member_id: 'absent' }),
      access('h', '2026-09-18T10:00:00Z', { member_id: 'absent', status: 'VOIDED' }),
    ] }));
    const byId = Object.fromEntries(r.member_frequency.map((m) => [m.member_id, m]));
    expect(byId.m).toMatchObject({ visits_current_period: 1, visits_previous_period: 2, member_frequency_change: -50, days_since_last_visit: 1 });
    expect(byId.stable.member_frequency_change).toBe(0);
    expect(byId.new.member_frequency_change).toBeNull();
    expect(byId.absent).toMatchObject({ visits_current_period: 0, days_since_last_visit: 49 });
    expect(calculateMetrics(input({ duration_days: 30, accesses: rows })).member_frequency[0].frequency_current_per_week).toBe(3 * 7 / 30);
  });
  it('uses IANA DST conversion while preserving equivalent elapsed durations', () => {
    const r = calculateMetrics(input({ gymUnit: { id: 'g', timezone: 'America/New_York' }, reference_instant: '2026-11-02T05:00:00Z',
      accesses: [access('a', '2026-11-01T05:30:00Z'), access('b', '2026-11-01T06:30:00Z')] }));
    expect(r.current.hourly_access_distribution[1]).toBe(2);
    expect(r.current.daily_access_distribution.at(-1)).toEqual({ date: '2026-11-01', count: 2 });
    expect(r.member_frequency[0].days_since_last_visit).toBe(1);
  });
  it('rejects cross-tenant members/accesses, orphan and duplicate facts', () => {
    expect(() => calculateMetrics(input({ members: [member('m', { gym_unit_id: 'other' })] }))).toThrow('Cross-tenant');
    for (const extra of [{ gym_unit_id: 'other' }, { member_id: 'other' }] as const)
      expect(() => calculateMetrics(input({ accesses: [access('a', '2026-09-10T10:00:00Z', extra)] }))).toThrow();
    const a = access('a', '2026-09-10T10:00:00Z');
    expect(() => calculateMetrics(input({ accesses: [a, a] }))).toThrow('Duplicate');
    expect(() => calculateMetrics(input({ members: [member(), member()] }))).toThrow('duplicate');
  });
  it('rejects ambiguous timestamps, invalid dates, timezone and unsupported periods', () => {
    for (const reference_instant of ['2026-09-19', '2026-09-19T00:00:00', '2026-02-30T03:00:00Z'])
      expect(() => calculateMetrics(input({ reference_instant }))).toThrow();
    expect(() => calculateMetrics(input({ gymUnit: { id: 'g', timezone: 'bad' } }))).toThrow();
    expect(() => comparablePeriods('2026-09-19T03:00:00Z', 14 as 7)).toThrow();
  });
  it('is deterministic, order independent and does not mutate inputs', () => {
    const value = input({ accesses: [access('a', '2026-09-13T10:00:00Z'), access('b', '2026-09-06T10:00:00Z')] });
    const saved = structuredClone(value);
    const first = calculateMetrics(value);
    expect(calculateMetrics(value)).toEqual(first);
    expect(calculateMetrics({ ...value, accesses: [...value.accesses].reverse() })).toEqual(first);
    expect(value).toEqual(saved);
  });
});

it('integrates the real in-memory Golden generator with the independent metrics core', () => {
  const dataset = generate();
  const run = (duration_days: 7 | 30) => calculateMetrics({ ...dataset, duration_days, reference_instant: '2026-09-19T03:00:00Z' });
  const seven = run(7), thirty = run(30);
  expect([seven.current.total_accesses, seven.previous.total_accesses]).toEqual([golden.observed.current7, golden.observed.previous7]);
  expect([thirty.current.total_accesses, thirty.previous.total_accesses]).toEqual([4853, 5616]);
  expect(seven.attendance_change_percentage).toBeCloseTo(-14.63, 2);
  expect(seven.current.active_members).toBe(500);
  expect(seven.current.average_visits_per_active_member).toBe(928 / 500);
  expect(seven.current.weekday_distribution[2]).toBe(141);
  expect(seven.previous.weekday_distribution[2]).toBe(177);
  expect(seven.current.weekday_distribution[3]).toBe(158);
  expect(seven.previous.weekday_distribution[3]).toBe(200);
  const band = (hours: number[], start: number, end: number) => hours.slice(start, end).reduce((a, b) => a + b, 0);
  expect(band(seven.current.hourly_access_distribution, 18, 20)).toBe(108);
  expect(band(seven.previous.hourly_access_distribution, 18, 20)).toBe(181);
  expect(band(seven.current.hourly_access_distribution, 6, 9)).toBe(406);
  expect(band(seven.previous.hourly_access_distribution, 6, 9)).toBe(401);
  expect(dataset.accesses.filter((a) => a.status === 'VOIDED')).toHaveLength(12);
  expect(calculateMetrics({ ...dataset, duration_days: 7, reference_instant: '2026-09-19T03:00:00Z',
    accesses: dataset.accesses.filter((a) => a.status === 'VALID') })).toEqual(seven);
  for (const r of [seven, thirty]) for (const metric of [r.current, r.previous]) {
    expect(metric.daily_access_distribution.reduce((sum, d) => sum + d.count, 0)).toBe(metric.total_accesses);
    expect(metric.hourly_access_distribution.reduce((a, b) => a + b, 0)).toBe(metric.total_accesses);
  }
});
