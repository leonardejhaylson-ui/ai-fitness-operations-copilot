export interface AnalyticalPeriod { readonly start: string; readonly end: string }
export interface ComparablePeriods {
  readonly current: AnalyticalPeriod;
  readonly previous: AnalyticalPeriod;
  readonly duration_days: 7 | 30;
}
export interface MemberInput {
  readonly id: string;
  readonly gym_unit_id: string;
  readonly joined_at: string;
  readonly deactivated_at: string | null;
  readonly deleted_at: string | null;
}
export interface AccessFactInput {
  readonly id: string;
  readonly gym_unit_id: string;
  readonly member_id: string;
  readonly occurred_at: string;
  readonly status: 'VALID' | 'VOIDED';
}
/** The caller must authorize this unit server-side and supply complete authorized history. */
export interface MetricsInput {
  readonly gymUnit: { readonly id: string; readonly timezone: string };
  readonly reference_instant: string;
  readonly duration_days: 7 | 30;
  readonly members: readonly MemberInput[];
  readonly accesses: readonly AccessFactInput[];
}
export interface PeriodMetrics {
  active_members: number;
  total_accesses: number;
  average_visits_per_active_member: number | null;
  daily_access_distribution: { date: string; count: number }[];
  /** Sunday = 0, Saturday = 6. */
  weekday_distribution: number[];
  /** Index is local hour 0..23; access flow, not simultaneous presence. */
  hourly_access_distribution: number[];
}
export interface MemberMetrics {
  member_id: string;
  visits_current_period: number;
  visits_previous_period: number;
  frequency_current_per_week: number;
  frequency_previous_per_week: number;
  member_frequency_change: number | null;
  last_visit_at: string | null;
  days_since_last_visit: number | null;
}
export interface MetricsResult {
  metadata: ComparablePeriods & {
    gym_unit_id: string; timezone: string; calculation_version: 'metrics-v1';
    period_semantics: '[start,end)'; last_visit_semantics: 'occurred_at <= reference_instant';
  };
  current: PeriodMetrics;
  previous: PeriodMetrics;
  attendance_change_percentage: number | null;
  member_frequency: MemberMetrics[];
}
