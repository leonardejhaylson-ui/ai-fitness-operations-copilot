import Link from 'next/link';
import { notFound } from 'next/navigation';
import { AppShell } from '@/components/app-shell';
import { MetricStrip } from '@/components/metric-strip';
import { loadDemoOperations } from '@/modules/application/demo-operations';
import { formatDate, formatDecimal, formatPercent } from '@/modules/presentation/format';

export default async function MemberDetailPage({ params }: { params: Promise<{ memberId: string }> }) {
  const { memberId } = await params;
  const data = loadDemoOperations();
  const member = data.members.find((item) => item.id === memberId);
  if (!member) notFound();

  const metric = data.metrics30.member_frequency.find((item) => item.member_id === memberId)!;
  const situations = data.insights.filter((item) => item.subject_id === memberId);

  return (
    <AppShell insightCount={data.insights.length}>
      <div className="page">
        <div className="breadcrumb"><Link href="/members">Alunos</Link><span>/</span><span>{member.display_name}</span></div>
        <header className="page-header">
          <div>
            <span className="eyebrow">{member.member_code} · Ativo</span>
            <h1>{member.display_name}</h1>
            <p>Comportamento individual de frequência</p>
          </div>
          <div className="header-actions"><Link href="/members" className="button-secondary">Voltar para Alunos</Link><Link href="/copilot" className="button-primary">Perguntar ao Copiloto</Link></div>
        </header>

        <MetricStrip items={[
          { label: 'Frequência recente', value: `${formatDecimal(metric.frequency_current_per_week)} / semana`, meta: 'últimos 30 dias' },
          { label: 'Frequência anterior', value: `${formatDecimal(metric.frequency_previous_per_week)} / semana`, meta: '30 dias anteriores' },
          { label: 'Variação', value: formatPercent(metric.member_frequency_change), meta: 'comparação equivalente' },
          { label: 'Último acesso', value: formatDate(metric.last_visit_at), meta: metric.days_since_last_visit === null ? 'sem histórico' : `há ${metric.days_since_last_visit} dias` },
        ]} />

        <section className="panel">
          <div className="section-heading"><div><h2>Situações detectadas</h2><p>Evidências determinísticas associadas ao aluno.</p></div></div>
          {situations.length ? situations.map((s, i) => (
            <div className="member-situation" key={i}>
              <span className={`severity-badge ${s.severity === 'HIGH' ? 'severity-high' : 'severity-warning'}`}>{s.severity === 'HIGH' ? 'Alta' : 'Atenção'}</span>
              <strong>{s.type === 'MEMBER_FREQUENCY_DROP' ? 'Redução relevante de frequência' : 'Ausência prolongada'}</strong>
              <p>{s.type === 'MEMBER_FREQUENCY_DROP' ? `${formatDecimal(metric.frequency_current_per_week)} visitas/semana vs. ${formatDecimal(metric.frequency_previous_per_week)} visitas/semana` : `${metric.days_since_last_visit ?? 0} dias desde o último acesso`}</p>
            </div>
          )) : <p className="empty-state">Nenhuma situação ativa para este aluno.</p>}
        </section>
      </div>
    </AppShell>
  );
}
