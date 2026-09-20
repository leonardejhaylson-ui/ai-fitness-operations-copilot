import { percentageChange } from '../metrics';
import type { MemberMetrics, MetricsResult } from '../metrics';
import { MVP_RULES_V1 } from './rules';
import type {
  InsightCandidate,
  InsightEngineInput,
  InsightMemberInput,
  InsightSeverity,
  InsightType,
} from './types';

export { MVP_RULES_V1 } from './rules';
export type * from './types';

function severityFor(change: number, highThreshold: number): InsightSeverity {
  return change <= highThreshold ? 'HIGH' : 'WARNING';
}

function baseCandidate(
  metrics: MetricsResult,
  type: InsightType,
  severity: InsightSeverity,
  subjectType: InsightCandidate['subject_type'],
  subjectId: string | null,
  evidence: InsightCandidate['evidence_snapshot'],
): InsightCandidate {
  return {
    type,
    severity,
    subject_type: subjectType,
    subject_id: subjectId,
    period_start: metrics.metadata.current.start,
    period_end: metrics.metadata.current.end,
    comparison_start: metrics.metadata.previous.start,
    comparison_end: metrics.metadata.previous.end,
    rule_code: type,
    rule_version: MVP_RULES_V1.version,
    evidence_snapshot: evidence,
  };
}

function validateInput(input: InsightEngineInput): Map<string, InsightMemberInput> {
  const { sevenDay, thirtyDay } = input;
  if (sevenDay.metadata.duration_days !== 7 || thirtyDay.metadata.duration_days !== 30)
    throw new Error('Insight Engine requires 7-day and 30-day metrics');
  if (sevenDay.metadata.gym_unit_id !== thirtyDay.metadata.gym_unit_id)
    throw new Error('Cross-tenant metrics');
  if (sevenDay.metadata.timezone !== thirtyDay.metadata.timezone)
    throw new Error('Mismatched metric timezone');
  if (sevenDay.metadata.current.end !== thirtyDay.metadata.current.end)
    throw new Error('Mismatched analytical reference');
  const members = new Map(input.members.map((member) => [member.id, member]));
  if (members.size !== input.members.length) throw new Error('Duplicate insight member');
  for (const metric of thirtyDay.member_frequency) {
    if (!members.has(metric.member_id)) throw new Error('Missing member status');
  }
  return members;
}

function attendanceInsight(metrics: MetricsResult): InsightCandidate[] {
  const change = metrics.attendance_change_percentage;
  const rule = MVP_RULES_V1.attendanceDrop;
  if (change === null || change > rule.warningChangePercentage) return [];
  return [baseCandidate(
    metrics,
    'ATTENDANCE_DROP',
    severityFor(change, rule.highChangePercentage),
    'GYM_UNIT',
    null,
    {
      schemaVersion: 'insight-evidence-v1',
      metric: 'attendance_change_percentage',
      current_accesses: metrics.current.total_accesses,
      previous_accesses: metrics.previous.total_accesses,
      change_percentage: change,
      warning_threshold_percentage: rule.warningChangePercentage,
      high_threshold_percentage: rule.highChangePercentage,
    },
  )];
}

function memberFrequencyInsights(metrics: MetricsResult): InsightCandidate[] {
  const rule = MVP_RULES_V1.memberFrequencyDrop;
  const insights: InsightCandidate[] = [];
  for (const member of metrics.member_frequency) {
    const change = member.member_frequency_change;
    const absoluteDrop = member.visits_previous_period - member.visits_current_period;
    if (
      change === null ||
      change > rule.warningChangePercentage ||
      member.visits_previous_period < rule.minimumReferenceAccesses ||
      absoluteDrop < rule.minimumAbsoluteDrop
    ) continue;
    insights.push(baseCandidate(
      metrics,
      'MEMBER_FREQUENCY_DROP',
      severityFor(change, rule.highChangePercentage),
      'MEMBER',
      member.member_id,
      {
        schemaVersion: 'insight-evidence-v1',
        metric: 'member_frequency_change',
        current_accesses: member.visits_current_period,
        previous_accesses: member.visits_previous_period,
        current_frequency_per_week: member.frequency_current_per_week,
        previous_frequency_per_week: member.frequency_previous_per_week,
        change_percentage: change,
        absolute_drop: absoluteDrop,
        warning_threshold_percentage: rule.warningChangePercentage,
        high_threshold_percentage: rule.highChangePercentage,
        minimum_reference_accesses: rule.minimumReferenceAccesses,
        minimum_absolute_drop: rule.minimumAbsoluteDrop,
      },
    ));
  }
  return insights;
}

function prolongedAbsenceInsights(
  metrics: MetricsResult,
  members: ReadonlyMap<string, InsightMemberInput>,
): InsightCandidate[] {
  const rule = MVP_RULES_V1.prolongedAbsence;
  const insights: InsightCandidate[] = [];
  for (const member of metrics.member_frequency) {
    const status = members.get(member.member_id)!.status;
    const days = member.days_since_last_visit;
    const historicalFrequency = member.frequency_previous_per_week;
    if (
      status !== 'ACTIVE' ||
      days === null ||
      days < rule.warningDays ||
      historicalFrequency < rule.minimumHistoricalFrequencyPerWeek
    ) continue;
    insights.push(baseCandidate(
      metrics,
      'PROLONGED_ABSENCE',
      days >= rule.highDays ? 'HIGH' : 'WARNING',
      'MEMBER',
      member.member_id,
      {
        schemaVersion: 'insight-evidence-v1',
        metric: 'days_since_last_visit',
        days_since_last_visit: days,
        last_visit_at: member.last_visit_at,
        historical_frequency_per_week: historicalFrequency,
        warning_threshold_days: rule.warningDays,
        high_threshold_days: rule.highDays,
        minimum_historical_frequency_per_week: rule.minimumHistoricalFrequencyPerWeek,
      },
    ));
  }
  return insights;
}

function hourlyFlowInsights(metrics: MetricsResult): InsightCandidate[] {
  const rule = MVP_RULES_V1.unusuallyLowOccupancy;
  if (metrics.previous.total_accesses === 0) return [];
  const insights: InsightCandidate[] = [];
  for (let hour = 0; hour < 24; hour++) {
    const current = metrics.current.hourly_access_distribution[hour] ?? 0;
    const previous = metrics.previous.hourly_access_distribution[hour] ?? 0;
    const change = percentageChange(current, previous);
    const referenceShare = previous / metrics.previous.total_accesses * 100;
    if (
      change === null ||
      change > rule.warningChangePercentage ||
      referenceShare < rule.minimumReferenceSharePercentage ||
      previous < rule.minimumReferenceCount
    ) continue;
    insights.push(baseCandidate(
      metrics,
      'UNUSUALLY_LOW_OCCUPANCY',
      severityFor(change, rule.highChangePercentage),
      'TIME_SLOT',
      null,
      {
        schemaVersion: 'insight-evidence-v1',
        metric: 'hourly_access_flow_change',
        hour_start_local: hour,
        hour_end_local: hour + 1,
        current_accesses: current,
        previous_accesses: previous,
        change_percentage: change,
        reference_share_percentage: referenceShare,
        warning_threshold_percentage: rule.warningChangePercentage,
        high_threshold_percentage: rule.highChangePercentage,
        minimum_reference_share_percentage: rule.minimumReferenceSharePercentage,
        minimum_reference_count: rule.minimumReferenceCount,
      },
    ));
  }
  return insights;
}

function stableSort(insights: InsightCandidate[]): InsightCandidate[] {
  const typeOrder: InsightType[] = [
    'ATTENDANCE_DROP',
    'MEMBER_FREQUENCY_DROP',
    'PROLONGED_ABSENCE',
    'UNUSUALLY_LOW_OCCUPANCY',
  ];
  return insights.sort((a, b) => {
    const type = typeOrder.indexOf(a.type) - typeOrder.indexOf(b.type);
    if (type !== 0) return type;
    const subject = (a.subject_id ?? '').localeCompare(b.subject_id ?? '');
    if (subject !== 0) return subject;
    const ah = Number(a.evidence_snapshot.hour_start_local ?? -1);
    const bh = Number(b.evidence_snapshot.hour_start_local ?? -1);
    return ah - bh;
  });
}

/**
 * Deterministic rule evaluation only.
 * Persistence, authorization, resolution lifecycle and presentation copy belong to outer layers.
 */
export function evaluateInsights(input: InsightEngineInput): InsightCandidate[] {
  const members = validateInput(input);
  return stableSort([
    ...attendanceInsight(input.sevenDay),
    ...memberFrequencyInsights(input.thirtyDay),
    ...prolongedAbsenceInsights(input.thirtyDay, members),
    ...hourlyFlowInsights(input.sevenDay),
  ]);
}

/** Exported for focused tests without duplicating the production member metric shape. */
export type { MemberMetrics };
