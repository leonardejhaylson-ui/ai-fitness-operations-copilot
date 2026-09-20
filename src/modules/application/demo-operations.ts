import { generate, type Dataset } from '../../../scripts/data/generator';
import { evaluateInsights, type InsightCandidate } from '../insights';
import { calculateMetrics, type MetricsResult } from '../metrics';

export const DEMO_REFERENCE_INSTANT = '2026-09-19T03:00:00Z';

export interface DemoMemberView {
  readonly id: string;
  readonly member_code: string;
  readonly display_name: string;
  readonly status: 'ACTIVE';
  readonly current_30d_visits: number;
  readonly previous_30d_visits: number;
  readonly frequency_change_percentage: number | null;
  readonly last_visit_at: string | null;
  readonly days_since_last_visit: number | null;
}

export interface DemoOperationsSnapshot {
  readonly gymUnit: Dataset['gymUnit'];
  readonly reference_instant: string;
  readonly metrics7: MetricsResult;
  readonly metrics30: MetricsResult;
  readonly insights: readonly InsightCandidate[];
  readonly members: readonly DemoMemberView[];
}

function buildSnapshot(dataset: Dataset): DemoOperationsSnapshot {
  const metrics7 = calculateMetrics({
    ...dataset,
    duration_days: 7,
    reference_instant: DEMO_REFERENCE_INSTANT,
  });
  const metrics30 = calculateMetrics({
    ...dataset,
    duration_days: 30,
    reference_instant: DEMO_REFERENCE_INSTANT,
  });
  const insights = evaluateInsights({
    sevenDay: metrics7,
    thirtyDay: metrics30,
    members: dataset.members.map((member) => ({ id: member.id, status: member.status })),
  });
  const metricsByMember = new Map(metrics30.member_frequency.map((member) => [member.member_id, member]));
  const members = dataset.members.map((member) => {
    const metric = metricsByMember.get(member.id);
    if (!metric) throw new Error('Missing member metrics');
    return {
      id: member.id,
      member_code: member.member_code,
      display_name: member.display_name,
      status: member.status,
      current_30d_visits: metric.visits_current_period,
      previous_30d_visits: metric.visits_previous_period,
      frequency_change_percentage: metric.member_frequency_change,
      last_visit_at: metric.last_visit_at,
      days_since_last_visit: metric.days_since_last_visit,
    } satisfies DemoMemberView;
  });

  return {
    gymUnit: dataset.gymUnit,
    reference_instant: DEMO_REFERENCE_INSTANT,
    metrics7,
    metrics30,
    insights,
    members,
  };
}

/**
 * Deterministic demo adapter for the synthetic MVP fixture.
 *
 * It is not an authorization boundary and must be replaced by the authorized
 * PostgreSQL adapter for real tenant data. Keeping it explicit avoids pretending
 * that demo fixture access is production data access.
 */
export function loadDemoOperations(): DemoOperationsSnapshot {
  return buildSnapshot(generate());
}
