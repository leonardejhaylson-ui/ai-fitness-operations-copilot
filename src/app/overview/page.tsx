import Link from 'next/link';
import { AppShell } from '@/components/app-shell';
import { MetricStrip } from '@/components/metric-strip';
import { InsightList } from '@/components/insight-list';
import { AccessBars } from '@/components/access-bars';
import { loadDemoOperations } from '@/modules/application/demo-operations';
import { formatDecimal, formatNumber, formatPercent } from '@/modules/presentation/format';

export default function OverviewPage() {
  const data = loadDemoOperations();
  const memberSituationIds = new Set(data.insights.filter((i) => i.subject_type === 'MEMBER' && i.subject_id).map((i) => i.subject_id));
  const band = (start: number, end: number) => data.metrics7.current.hourly_access_distribution.slice(start, end).reduce((a, b) => a + b, 0);
  const hourBands = [band(6, 9), band(9, 12), band(12, 15), band(15, 18), band(18, 21), band(21, 23)];

  return (
    <AppShell insightCount={data.insights.length}>
      <div className="page">
        <header className="page-header">
          <div>
            <span className="eyebrow">{data.gymUnit.name}</span>
            <h1>Visão geral</h1>
            <p>Últimos 7 dias vs. 7 dias anteriores</p>
          </div>
          <Link href="/copilot" className="button-secondary">Perguntar ao Copiloto</Link>
        </header>

        <MetricStrip items={[
          { label: 'Alunos ativos', value: formatNumber(data.metrics7.current.active_members), meta: 'no fim do período' },
          { label: 'Acessos', value: formatNumber(data.metrics7.current.total_accesses), meta: formatPercent(data.metrics7.attendance_change_percentage) },
          { label: 'Visitas médias por aluno ativo', value: formatDecimal(data.metrics7.current.average_visits_per_active_member ?? 0), meta: 'no período selecionado' },
          { label: 'Alunos com situação ativa', value: formatNumber(memberSituationIds.size), meta: 'regras de aluno' },
        ]} />

        <div className="overview-grid">
          <section className="panel panel-wide">
            <div className="section-heading">
              <div>
                <h2>Evolução de acessos</h2>
                <p>Volume diário no período atual.</p>
              </div>
              <Link href="/attendance" className="text-action">Ver frequência</Link>
            </div>
            <AccessBars values={data.metrics7.current.daily_access_distribution.map((d) => d.count)}
              labels={data.metrics7.current.daily_access_distribution.map((d) => d.date.slice(8, 10))} />
          </section>

          <section className="panel">
            <div className="section-heading">
              <div>
                <h2>Situações prioritárias</h2>
                <p>{data.insights.length} situações ativas</p>
              </div>
              <Link href="/insights" className="text-action">Ver todas</Link>
            </div>
            <InsightList insights={data.insights} limit={4} />
          </section>
        </div>

        <section className="panel">
          <div className="section-heading">
            <div>
              <h2>Distribuição de acessos por horário</h2>
              <p>Fluxo de acessos por faixa horária. Não representa presença simultânea.</p>
            </div>
            <Link href="/attendance" className="text-action">Ver frequência</Link>
          </div>
          <AccessBars values={hourBands} labels={['06–09','09–12','12–15','15–18','18–21','21–23']} />
        </section>
      </div>
    </AppShell>
  );
}
