import type { ComparablePeriods } from './types';
export const DAY_MS = 86_400_000;

export function instant(value: string): number {
  if (!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,3})?(?:Z|[+-]\d{2}:\d{2})$/.test(value))
    throw new Error('Expected an ISO timestamp with explicit offset');
  const result = Date.parse(value);
  const date = value.slice(0, 10);
  if (!Number.isFinite(result) || new Date(`${date}T00:00:00Z`).toISOString().slice(0, 10) !== date)
    throw new Error('Invalid timestamp');
  return result;
}

/** Equal elapsed durations, anchored to an explicit exclusive reference instant. */
export function comparablePeriods(reference: string, days: 7 | 30): ComparablePeriods {
  if (days !== 7 && days !== 30) throw new Error('Unsupported period');
  const end = instant(reference);
  const start = end - days * DAY_MS;
  return {
    current: { start: new Date(start).toISOString(), end: new Date(end).toISOString() },
    previous: { start: new Date(start - days * DAY_MS).toISOString(), end: new Date(start).toISOString() },
    duration_days: days,
  };
}

export function localClock(timezone: string) {
  const formatter = new Intl.DateTimeFormat('en-US', {
    timeZone: timezone, year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', hourCycle: 'h23',
  });
  return (time: number) => {
    const parts = formatter.formatToParts(time);
    const part = (name: string) => parts.find((p) => p.type === name)!.value;
    const date = `${part('year')}-${part('month')}-${part('day')}`;
    const ordinal = Date.parse(`${date}T00:00:00Z`) / DAY_MS;
    return { date, ordinal, weekday: new Date(ordinal * DAY_MS).getUTCDay(), hour: Number(part('hour')) };
  };
}
