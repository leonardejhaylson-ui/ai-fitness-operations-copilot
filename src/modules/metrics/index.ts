import { comparablePeriods, DAY_MS, instant, localClock } from './periods';
import type { AnalyticalPeriod, MetricsInput, MetricsResult, PeriodMetrics } from './types';
export { comparablePeriods } from './periods';
export type * from './types';

/** A zero reference, including 0 -> 0, is not comparable. No rounding in core. */
export function percentageChange(current: number, previous: number): number | null {
  return previous === 0 ? null : ((current - previous) / previous) * 100;
}

export function calculateMetrics(input: MetricsInput): MetricsResult {
  const periods = comparablePeriods(input.reference_instant, input.duration_days);
  const local = localClock(input.gymUnit.timezone);
  const end = instant(periods.current.end);
  const start = instant(periods.current.start);
  const previousStart = instant(periods.previous.start);
  const members = new Map(input.members.map((member) => [member.id, member]));
  if (!input.gymUnit.id || members.size !== input.members.length) throw new Error('Invalid unit or duplicate member');
  for (const member of input.members) {
    if (member.gym_unit_id !== input.gymUnit.id) throw new Error('Cross-tenant member');
    const joined = instant(member.joined_at);
    if (member.deactivated_at !== null && instant(member.deactivated_at) < joined) throw new Error('Invalid member lifecycle');
    if (member.deleted_at !== null) instant(member.deleted_at);
  }
  const initialize = (period: AnalyticalPeriod): PeriodMetrics => {
    const boundary = instant(period.end);
    const active = input.members.filter((member) => instant(member.joined_at) < boundary &&
      (member.deactivated_at === null || instant(member.deactivated_at) >= boundary) && member.deleted_at === null).length;
    const days = [];
    for (let day = local(instant(period.start)).ordinal; day <= local(boundary - 1).ordinal; day++)
      days.push({ date: new Date(day * DAY_MS).toISOString().slice(0, 10), count: 0 });
    return { active_members: active, total_accesses: 0, average_visits_per_active_member: null,
      daily_access_distribution: days, weekday_distribution: Array<number>(7).fill(0), hourly_access_distribution: Array<number>(24).fill(0) };
  };
  const current = initialize(periods.current);
  const previous = initialize(periods.previous);
  const frequencies = new Map(input.members.map((m) => [m.id, { current: 0, previous: 0, last: null as number | null }]));
  const ids = new Set<string>();
  for (const access of input.accesses) {
    if (access.gym_unit_id !== input.gymUnit.id) throw new Error('Cross-tenant access');
    if (!members.has(access.member_id)) throw new Error('Unknown member');
    if (ids.has(access.id)) throw new Error('Duplicate access');
    ids.add(access.id);
    const time = instant(access.occurred_at);
    if (access.status !== 'VALID' && access.status !== 'VOIDED') throw new Error('Invalid access status');
    if (access.status === 'VOIDED') continue;
    const frequency = frequencies.get(access.member_id)!;
    // Specification §32 uses an inclusive analytical instant, independently of interval counts.
    if (time <= end && (frequency.last === null || time > frequency.last)) frequency.last = time;
    if (time < previousStart || time >= end) continue;
    const metric = time >= start ? current : previous;
    if (time >= start) frequency.current++; else frequency.previous++;
    metric.total_accesses++;
    const parts = local(time);
    metric.daily_access_distribution.find((day) => day.date === parts.date)!.count++;
    metric.weekday_distribution[parts.weekday]++;
    metric.hourly_access_distribution[parts.hour]++;
  }
  for (const metric of [current, previous]) metric.average_visits_per_active_member =
    metric.active_members === 0 ? null : metric.total_accesses / metric.active_members;
  return {
    metadata: { ...periods, gym_unit_id: input.gymUnit.id, timezone: input.gymUnit.timezone,
      calculation_version: 'metrics-v1', period_semantics: '[start,end)', last_visit_semantics: 'occurred_at <= reference_instant' },
    current, previous, attendance_change_percentage: percentageChange(current.total_accesses, previous.total_accesses),
    member_frequency: [...frequencies].sort(([a], [b]) => a < b ? -1 : a > b ? 1 : 0).map(([id, f]) => ({
      member_id: id, visits_current_period: f.current, visits_previous_period: f.previous,
      frequency_current_per_week: f.current * 7 / input.duration_days,
      frequency_previous_per_week: f.previous * 7 / input.duration_days,
      member_frequency_change: percentageChange(f.current, f.previous),
      last_visit_at: f.last === null ? null : new Date(f.last).toISOString(),
      days_since_last_visit: f.last === null ? null : local(end).ordinal - local(f.last).ordinal,
    })),
  };
}
