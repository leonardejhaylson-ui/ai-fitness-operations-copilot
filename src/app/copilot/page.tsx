import Link from 'next/link';
import { AppShell } from '@/components/app-shell';
import { CopilotPanel } from '@/components/copilot-panel';
import { loadDemoOperations } from '@/modules/application/demo-operations';

export default function CopilotPage() {
  const data = loadDemoOperations();
  return (
    <AppShell insightCount={data.insights.length}>
      <div className="page">
        <header className="page-header">
          <div>
            <span className="eyebrow">Contexto da análise · {data.gymUnit.name}</span>
            <h1>Investigue os dados da unidade</h1>
            <p>Faça uma pergunta sobre frequência, alunos, situações detectadas ou distribuição de acessos.</p>
          </div>
        </header>
        <div className="copilot-layout">
          <CopilotPanel />
          <aside className="panel context-panel">
            <h2>Contexto da análise</h2>
            <dl>
              <div><dt>Unidade</dt><dd>{data.gymUnit.name}</dd></div>
              <div><dt>Período</dt><dd>Últimos 7 dias</dd></div>
              <div><dt>Comparação</dt><dd>7 dias anteriores</dd></div>
              <div><dt>Fonte</dt><dd>Métricas e situações determinísticas</dd></div>
            </dl>
            <Link href="/overview" className="text-action">Voltar para Visão geral</Link>
          </aside>
        </div>
      </div>
    </AppShell>
  );
}
