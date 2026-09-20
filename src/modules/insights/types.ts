import type { MetricsResult } from '../metrics';

export type InsightType =
  | 'ATTENDANCE_DROP'
  | 'MEMBER_FREQUENCY_DROP'
  | 'PROLONGED_ABSENCE'
  | 'UNUSUALLY_LOW_OCCUPANCY';

export type InsightSeverity = 'WARNING' | 'HIGH';
export type InsightSubjectType = 'GYM_UNIT' | 'MEMBER' | 'TIME_SLOT';

export interface InsightMemberInput {
  readonly id: string;
  readonly status: 'ACTIVE' | 'INACTIVE';
}

export interface InsightEngineInput {
  readonly sevenDay: MetricsResult;
  readonly thirtyDay: MetricsResult;
  readonly members: readonly InsightMemberInput[];
}

export interface InsightEvidenceSnapshot {
  readonly schemaVersion: 'insight-evidence-v1';
  readonly metric: string;
  readonly [key: string]: string | number | null;
}

export interface InsightCandidate {
  readonly type: InsightType;
  readonly severity: InsightSeverity;
  readonly subject_type: InsightSubjectType;
  readonly subject_id: string | null;
  readonly period_start: string;
  readonly period_end: string;
  readonly comparison_start: string;
  readonly comparison_end: string;
  readonly rule_code: InsightType;
  readonly rule_version: 'MVP_RULES_V1';
  readonly evidence_snapshot: InsightEvidenceSnapshot;
}
