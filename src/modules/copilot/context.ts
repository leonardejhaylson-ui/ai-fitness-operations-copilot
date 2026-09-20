import { loadDemoOperations } from '../application/demo-operations';
import { formatDecimal, formatNumber, formatPercent } from '../presentation/format';

export interface CopilotEvidence {
  readonly id: string;
  readonly label: string;
  readonly value: string;
  readonly source: 'METRIC' | 'BREAKDOWN' | 'INSIGHT';
}

export interface CopilotContext {
  readonly gym_unit: { readonly id: string; readonly name: string };
  readonly period: {
    readonly label: string;
    readonly current_start: string;
    readonly current_end: string;
    readonly comparison_start: string;
    readonly comparison_end: string;
  };
  readonly facts: readonly CopilotEvidence[];
  readonly limitations: readonly string[];
}

export function buildDemoCopilotContext(): CopilotContext {
  const data = loadDemoOperations();
  const facts: CopilotEvidence[] = [];

  facts.push(
    {
      id: 'E1',
      label: 'Acessos totais',
      value: `${formatNumber(data.metrics7.current.total_accesses)} acessos atuais vs. ${formatNumber(data.metrics7.previous.total_accesses)} anteriores (${formatPercent(data.metrics7.attendance_change_percentage)})`,
      source: 'METRIC',
    },
    {
      id: 'E2',
      label: 'Alunos ativos',
      value: `${formatNumber(data.metrics7.current.active_members)} alunos ativos`,
      source: 'METRIC',
    },
    {
      id: 'E3',
      label: 'Visitas médias por aluno ativo',
      value: `${formatDecimal(data.metrics7.current.average_visits_per_active_member ?? 0)} no período selecionado`,
      source: 'METRIC',
    },
  );

  const weekday = data.metrics7.current.weekday_distribution;
  const previousWeekday = data.metrics7.previous.weekday_distribution;
  facts.push(
    {
      id: 'E4',
      label: 'Terça-feira',
      value: `${formatNumber(weekday[2])} acessos atuais vs. ${formatNumber(previousWeekday[2])} anteriores`,
      source: 'BREAKDOWN',
    },
    {
      id: 'E5',
      label: 'Quarta-feira',
      value: `${formatNumber(weekday[3])} acessos atuais vs. ${formatNumber(previousWeekday[3])} anteriores`,
      source: 'BREAKDOWN',
    },
  );

  const sum = (values: readonly number[], start: number, end: number) =>
    values.slice(start, end).reduce((total, value) => total + value, 0);

  facts.push(
    {
      id: 'E6',
      label: 'Fluxo 18:00–20:00',
      value: `${formatNumber(sum(data.metrics7.current.hourly_access_distribution, 18, 20))} acessos atuais vs. ${formatNumber(sum(data.metrics7.previous.hourly_access_distribution, 18, 20))} anteriores`,
      source: 'BREAKDOWN',
    },
    {
      id: 'E7',
      label: 'Fluxo 06:00–09:00',
      value: `${formatNumber(sum(data.metrics7.current.hourly_access_distribution, 6, 9))} acessos atuais vs. ${formatNumber(sum(data.metrics7.previous.hourly_access_distribution, 6, 9))} anteriores`,
      source: 'BREAKDOWN',
    },
  );

  const memberDropCount = data.insights.filter((i) => i.type === 'MEMBER_FREQUENCY_DROP').length;
  const absenceCount = data.insights.filter((i) => i.type === 'PROLONGED_ABSENCE').length;
  facts.push(
    {
      id: 'E8',
      label: 'Alunos com redução relevante de frequência',
      value: `${formatNumber(memberDropCount)} situações detectadas pela regra determinística`,
      source: 'INSIGHT',
    },
    {
      id: 'E9',
      label: 'Ausências prolongadas',
      value: `${formatNumber(absenceCount)} situações detectadas pela regra determinística`,
      source: 'INSIGHT',
    },
  );

  return {
    gym_unit: { id: data.gymUnit.id, name: data.gymUnit.name },
    period: {
      label: 'Últimos 7 dias vs. 7 dias anteriores',
      current_start: data.metrics7.metadata.current.start,
      current_end: data.metrics7.metadata.current.end,
      comparison_start: data.metrics7.metadata.previous.start,
      comparison_end: data.metrics7.metadata.previous.end,
    },
    facts,
    limitations: [
      'Os dados disponíveis mostram padrões de acesso, mas não determinam causas externas.',
      'Não há dados de clima, campanhas, preço, motivos declarados pelos alunos ou permanência simultânea na unidade.',
      'Sinais de redução de frequência ou ausência não representam previsão de cancelamento.',
    ],
  };
}
