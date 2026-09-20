import { AppShell } from '@/components/app-shell';
import { InsightList } from '@/components/insight-list';
import { loadDemoOperations } from '@/modules/application/demo-operations';

export default function InsightsPage() {
  const data = loadDemoOperations();
  return (
    <AppShell insightCount={data.insights.length}>
      <div className="page">
        <header className="page-header">
          <div>
            <span className="eyebrow">{data.gymUnit.name}</span>
            <h1>Situações</h1>
            <p>{data.insights.length} situações ativas</p>
          </div>
        </header>
        <div className="filters-row">
          <div className="filter-box"><span>Severidade</span><strong>Todas</strong></div>
          <div className="filter-box"><span>Tipo</span><strong>Todos</strong></div>
        </div>
        <section className="panel panel-flush">
          <InsightList insights={data.insights} />
        </section>
      </div>
    </AppShell>
  );
}
