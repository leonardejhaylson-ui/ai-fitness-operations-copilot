import Link from 'next/link';
import { AppShell } from '@/components/app-shell';
import { MetricStrip } from '@/components/metric-strip';
import { AccessBars } from '@/components/access-bars';
import { InsightList } from '@/components/insight-list';
import { loadDemoOperations } from '@/modules/application/demo-operations';
import { formatDecimal, formatNumber, formatPercent } from '@/modules/presentation/format';

export default function AttendancePage() {
  const data = loadDemoOperations();
  const hourly = data.metrics7.current.hourly_access_distribution;
  return (
    <AppShell insightCount={data.insights.length}>
      <div className="page">
        <header className="page-header">
          <div>
            <span className="eyebrow">{data.gymUnit.name}</span>
            <h1>Frequência</h1>
            <p>Últimos 7 dias vs. 7 dias anteriores</p>
          </div>
          <div className="header-actions">
            <Link href="/members" className="button-secondary">Ver alunos</Link>
            <Link href="/copilot" className="button-primary">Perguntar ao Copiloto</Link>
          </div>
        </header>

        <MetricStrip items={[
          { label: 'Acessos', value: formatNumber(data.metrics7.current.total_accesses), meta: 'últimos 7 dias' },
          { label: 'Variação de acessos', value: formatPercent(data.metrics7.attendance_change_percentage), meta: 'vs. período anterior' },
          { label: 'Visitas médias por aluno ativo', value: formatDecimal(data.metrics7.current.average_visits_per_active_member ?? 0), meta: 'no período selecionado' },
        ]} />

        <section className="panel">
          <div className="section-heading"><div><h2>Evolução de acessos</h2><p>Atual comparado ao período anterior equivalente.</p></div></div>
          <AccessBars values={data.metrics7.current.daily_access_distribution.map((d) => d.count)}
            labels={data.metrics7.current.daily_access_distribution.map((d) => d.date.slice(8, 10))} />
        </section>

        <section className="panel">
          <div className="section-heading"><div><h2>Distribuição por dia</h2><p>Acessos válidos por dia local da unidade.</p></div></div>
          <div className="comparison-table">
            <div className="comparison-head"><span>Data</span><span>Atual</span><span>Anterior</span></div>
            {data.metrics7.current.daily_access_distribution.map((day, index) => (
              <div className="comparison-row" key={day.date}>
                <span>{day.date.split('-').reverse().slice(0,2).join('/')}</span>
                <strong>{formatNumber(day.count)}</strong>
                <span>{formatNumber(data.metrics7.previous.daily_access_distribution[index]?.count ?? 0)}</span>
              </div>
            ))}
          </div>
        </section>

        <section className="panel">
          <div className="section-heading"><div><h2>Distribuição de acessos por horário</h2><p>Fluxo horário; não mede pessoas presentes simultaneamente.</p></div></div>
          <AccessBars values={hourly.slice(6, 23)} labels={Array.from({ length: 17 }, (_, i) => `${String(i + 6).padStart(2,'0')}h`)} />
        </section>

        <section className="panel">
          <div className="section-heading"><div><h2>Situações relacionadas</h2><p>Sinais determinísticos ligados à frequência.</p></div></div>
          <InsightList insights={data.insights.filter((i) => i.type === 'ATTENDANCE_DROP' || i.type === 'UNUSUALLY_LOW_OCCUPANCY')} />
        </section>
      </div>
    </AppShell>
  );
}
