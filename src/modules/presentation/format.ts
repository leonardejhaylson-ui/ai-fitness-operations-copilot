import type { InsightCandidate } from '../insights';

export function formatNumber(value: number): string {
  return new Intl.NumberFormat('pt-BR').format(value);
}

export function formatDecimal(value: number): string {
  return new Intl.NumberFormat('pt-BR', { minimumFractionDigits: 1, maximumFractionDigits: 1 }).format(value);
}

export function formatPercent(value: number | null): string {
  if (value === null) return 'Comparação indisponível';
  const number = new Intl.NumberFormat('pt-BR', {
    minimumFractionDigits: 1,
    maximumFractionDigits: 1,
    signDisplay: 'always',
  }).format(value);
  return `${number}%`;
}

export function formatDate(value: string | null): string {
  if (!value) return 'Sem histórico';
  return new Intl.DateTimeFormat('pt-BR', { day: '2-digit', month: 'short', year: 'numeric', timeZone: 'America/Sao_Paulo' })
    .format(new Date(value))
    .replace('.', '');
}

export function insightTitle(insight: InsightCandidate): string {
  switch (insight.type) {
    case 'ATTENDANCE_DROP': return 'Queda relevante de acessos';
    case 'MEMBER_FREQUENCY_DROP': return 'Redução relevante de frequência';
    case 'PROLONGED_ABSENCE': return 'Ausência prolongada';
    case 'UNUSUALLY_LOW_OCCUPANCY': return 'Redução no fluxo de acessos por horário';
  }
}

export function insightSummary(insight: InsightCandidate): string {
  const e = insight.evidence_snapshot;
  switch (insight.type) {
    case 'ATTENDANCE_DROP':
      return `${formatNumber(Number(e.current_accesses))} vs. ${formatNumber(Number(e.previous_accesses))} acessos`;
    case 'MEMBER_FREQUENCY_DROP':
      return `${formatNumber(Number(e.current_accesses))} vs. ${formatNumber(Number(e.previous_accesses))} acessos em 30 dias`;
    case 'PROLONGED_ABSENCE':
      return `${formatNumber(Number(e.days_since_last_visit))} dias desde o último acesso`;
    case 'UNUSUALLY_LOW_OCCUPANCY':
      return `${String(e.hour_start_local).padStart(2, '0')}:00–${String(e.hour_end_local).padStart(2, '0')}:00 · fluxo de acessos`;
  }
}

export function insightDestination(insight: InsightCandidate): string {
  if (insight.type === 'ATTENDANCE_DROP' || insight.type === 'UNUSUALLY_LOW_OCCUPANCY') return '/attendance';
  if (insight.subject_id) return `/members/${insight.subject_id}`;
  return '/members';
}
