// @vitest-environment node
import { describe, expect, it } from 'vitest';
import { calculateMetrics, type MemberMetrics, type MetricsResult } from '../metrics';
import { evaluateInsights } from './index';
import { generate } from '../../../scripts/data/generator';
import golden from '../../../scripts/data/golden.json';

function memberMetric(extra: Partial<MemberMetrics> = {}): MemberMetrics {
  return {
    member_id: 'm1',
    visits_current_period: 6,
    visits_previous_period: 10,
    frequency_current_per_week: 1.4,
    frequency_previous_per_week: 2.3333333333333335,
    member_frequency_change: -40,
    last_visit_at: '2026-09-10T10:00:00.000Z',
    days_since_last_visit: 9,
    ...extra,
  };
}

function metrics(days: 7 | 30, extra: Partial<MetricsResult> = {}): MetricsResult {
  const end = '2026-09-19T03:00:00.000Z';
  const currentStart = new Date(Date.parse(end) - days * 86_400_000).toISOString();
  const previousStart = new Date(Date.parse(currentStart) - days * 86_400_000).toISOString();
  return {
    metadata: {
      current: { start: currentStart, end },
      previous: { start: previousStart, end: currentStart },
      duration_days: days,
      gym_unit_id: 'g',
      timezone: 'America/Sao_Paulo',
      calculation_version: 'metrics-v1',
      period_semantics: '[start,end)',
      last_visit_semantics: 'occurred_at <= reference_instant',
    },
    current: {
      active_members: 1,
      total_accesses: 90,
      average_visits_per_active_member: 90,
      daily_access_distribution: [],
      weekday_distribution: Array(7).fill(0),
      hourly_access_distribution: Array(24).fill(0),
    },
    previous: {
      active_members: 1,
      total_accesses: 100,
      average_visits_per_active_member: 100,
      daily_access_distribution: [],
      weekday_distribution: Array(7).fill(0),
      hourly_access_distribution: Array(24).fill(0),
    },
    attendance_change_percentage: -10,
    member_frequency: [memberMetric()],
    ...extra,
  };
}

function input(seven = metrics(7), thirty = metrics(30)) {
  return { sevenDay: seven, thirtyDay: thirty, members: [{ id: 'm1', status: 'ACTIVE' as const }] };
}

describe('Insight Engine rule boundaries', () => {
  it('maps attendance thresholds deterministically', () => {
    const at = (change: number | null) => evaluateInsights(input(metrics(7, { attendance_change_percentage: change })))
      .filter((i) => i.type === 'ATTENDANCE_DROP');

    expect(at(-9.99)).toHaveLength(0);
    expect(at(null)).toHaveLength(0);
    expect(at(-10)[0]?.severity).toBe('WARNING');
    expect(at(-19.9)[0]?.severity).toBe('WARNING');
    expect(at(-20)[0]?.severity).toBe('HIGH');
  });

  it('requires member decline magnitude, baseline and absolute drop', () => {
    const run = (metric: MemberMetrics) => evaluateInsights(input(
      metrics(7, { attendance_change_percentage: 0 }),
      metrics(30, { member_frequency: [metric] }),
    )).filter((i) => i.type === 'MEMBER_FREQUENCY_DROP');

    expect(run(memberMetric({ visits_current_period: 7, visits_previous_period: 10, member_frequency_change: -30 }))).toHaveLength(0);
    expect(run(memberMetric({ visits_current_period: 6, visits_previous_period: 10, member_frequency_change: -40 }))[0]?.severity).toBe('WARNING');
    expect(run(memberMetric({ visits_current_period: 3, visits_previous_period: 5, member_frequency_change: -40 }))).toHaveLength(1);
    expect(run(memberMetric({ visits_current_period: 0, visits_previous_period: 1, member_frequency_change: -100 }))).toHaveLength(0);
    expect(run(memberMetric({ visits_current_period: 4, visits_previous_period: 10, member_frequency_change: -60 }))[0]?.severity).toBe('HIGH');
  });

  it('requires ACTIVE status, absence threshold and historical frequency', () => {
    const thirty = metrics(30, {
      member_frequency: [memberMetric({
        days_since_last_visit: 10,
        frequency_previous_per_week: 1,
        member_frequency_change: 0,
      })],
    });
    const warnings = evaluateInsights(input(metrics(7, { attendance_change_percentage: 0 }), thirty))
      .filter((i) => i.type === 'PROLONGED_ABSENCE');
    expect(warnings[0]?.severity).toBe('WARNING');

    const high = metrics(30, { member_frequency: [memberMetric({
      days_since_last_visit: 21,
      frequency_previous_per_week: 1,
      member_frequency_change: 0,
    })] });
    expect(evaluateInsights(input(metrics(7, { attendance_change_percentage: 0 }), high))
      .find((i) => i.type === 'PROLONGED_ABSENCE')?.severity).toBe('HIGH');

    const lowHistory = metrics(30, { member_frequency: [memberMetric({
      days_since_last_visit: 15,
      frequency_previous_per_week: 0.3,
      member_frequency_change: 0,
    })] });
    expect(evaluateInsights(input(metrics(7, { attendance_change_percentage: 0 }), lowHistory))
      .some((i) => i.type === 'PROLONGED_ABSENCE')).toBe(false);

    expect(evaluateInsights({ ...input(metrics(7, { attendance_change_percentage: 0 }), thirty),
      members: [{ id: 'm1', status: 'INACTIVE' }] })
      .some((i) => i.type === 'PROLONGED_ABSENCE')).toBe(false);
  });

  it('detects relevant hourly access-flow changes without low-volume false positives', () => {
    const hourly = (previous: number, current: number, previousTotal = 100) => {
      const seven = metrics(7, { attendance_change_percentage: 0 });
      seven.previous.total_accesses = previousTotal;
      seven.current.total_accesses = previousTotal;
      seven.previous.hourly_access_distribution[18] = previous;
      seven.current.hourly_access_distribution[18] = current;
      return evaluateInsights(input(seven)).filter((i) => i.type === 'UNUSUALLY_LOW_OCCUPANCY');
    };

    expect(hourly(20, 17)).toHaveLength(0);
    expect(hourly(20, 15)[0]?.severity).toBe('WARNING');
    expect(hourly(20, 12)[0]?.severity).toBe('HIGH');
    expect(hourly(3, 1)).toHaveLength(0);
    expect(hourly(20, 15, 1000)).toHaveLength(0);
  });

  it('rejects mixed metric contexts and incomplete member status input', () => {
    const other = metrics(30);
    other.metadata.gym_unit_id = 'other';
    expect(() => evaluateInsights(input(metrics(7), other))).toThrow('Cross-tenant');

    const wrongEndBase = metrics(30);
    const wrongEnd: MetricsResult = {
      ...wrongEndBase,
      metadata: {
        ...wrongEndBase.metadata,
        current: { ...wrongEndBase.metadata.current, end: '2026-09-20T03:00:00.000Z' },
      },
    };
    expect(() => evaluateInsights(input(metrics(7), wrongEnd))).toThrow('reference');

    expect(() => evaluateInsights({ sevenDay: metrics(7), thirtyDay: metrics(30), members: [] }))
      .toThrow('Missing member status');
  });
});

it('detects the approved Golden Dataset situations from deterministic metrics', () => {
  const dataset = generate();
  const reference_instant = '2026-09-19T03:00:00Z';
  const sevenDay = calculateMetrics({ ...dataset, duration_days: 7, reference_instant });
  const thirtyDay = calculateMetrics({ ...dataset, duration_days: 30, reference_instant });
  const insights = evaluateInsights({
    sevenDay,
    thirtyDay,
    members: dataset.members.map((member) => ({ id: member.id, status: member.status })),
  });

  expect(insights.some((i) => i.type === 'ATTENDANCE_DROP')).toBe(true);
  expect(insights.some((i) => i.type === 'MEMBER_FREQUENCY_DROP')).toBe(true);
  expect(insights.some((i) => i.type === 'PROLONGED_ABSENCE')).toBe(true);
  expect(insights.some((i) => i.type === 'UNUSUALLY_LOW_OCCUPANCY')).toBe(true);

  const hourly = insights.filter((i) => i.type === 'UNUSUALLY_LOW_OCCUPANCY');
  expect(hourly.some((i) => [18, 19].includes(Number(i.evidence_snapshot.hour_start_local)))).toBe(true);

  const declining = new Set(golden.expected.memberSignals.declining);
  expect(insights.some((i) => i.type === 'MEMBER_FREQUENCY_DROP' && i.subject_id !== null && declining.has(i.subject_id))).toBe(true);

  const absent = new Set(golden.expected.memberSignals.absent);
  expect(insights.some((i) => i.type === 'PROLONGED_ABSENCE' && i.subject_id !== null && absent.has(i.subject_id))).toBe(true);

  expect(insights.every((i) => i.rule_version === 'MVP_RULES_V1')).toBe(true);
  expect(insights.every((i) => i.evidence_snapshot.schemaVersion === 'insight-evidence-v1')).toBe(true);
  expect(insights.every((i) => i.severity === 'WARNING' || i.severity === 'HIGH')).toBe(true);
});
