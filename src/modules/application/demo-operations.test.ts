// @vitest-environment node
import { describe, expect, it } from 'vitest';
import { loadDemoOperations } from './demo-operations';

describe('demo application orchestration', () => {
  it('builds one deterministic operational snapshot from the approved fixture', () => {
    const first = loadDemoOperations();
    const second = loadDemoOperations();

    expect(second).toEqual(first);
    expect(first.gymUnit.timezone).toBe('America/Sao_Paulo');
    expect(first.metrics7.current.total_accesses).toBe(928);
    expect(first.metrics7.previous.total_accesses).toBe(1087);
    expect(first.metrics30.current.total_accesses).toBe(4853);
    expect(first.metrics30.previous.total_accesses).toBe(5616);
    expect(first.members).toHaveLength(500);
    expect(first.insights.length).toBeGreaterThan(0);
  });

  it('keeps the application view free of synthetic behavior labels', () => {
    const snapshot = loadDemoOperations();
    for (const member of snapshot.members) {
      expect(member).not.toHaveProperty('synthetic_profile');
      expect(member).not.toHaveProperty('profile');
    }
  });

  it('exposes facts and deterministic situations without persisting metrics', () => {
    const snapshot = loadDemoOperations();
    expect(snapshot.insights.some((insight) => insight.type === 'ATTENDANCE_DROP')).toBe(true);
    expect(snapshot.insights.some((insight) => insight.type === 'MEMBER_FREQUENCY_DROP')).toBe(true);
    expect(snapshot.insights.some((insight) => insight.type === 'PROLONGED_ABSENCE')).toBe(true);
    expect(snapshot.insights.some((insight) => insight.type === 'UNUSUALLY_LOW_OCCUPANCY')).toBe(true);
  });
});
