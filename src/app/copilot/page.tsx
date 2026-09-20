import Link from 'next/link';
import { AppShell } from '@/components/app-shell';
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
          <section className="panel copilot-main">
            <div className="copilot-empty">
              <span className="copilot-kicker">Copiloto</span>
              <h2>O que você quer investigar?</h2>
              <div className="suggestion-list">
                <button>O que mudou nos últimos 7 dias?</button>
                <button>Onde a frequência mais mudou?</button>
                <button>Quais alunos apresentam redução relevante?</button>
                <button>Quais situações estão ativas?</button>
              </div>
            </div>
            <div className="prompt-bar">
              <input disabled placeholder="Faça uma pergunta sobre os dados da unidade" aria-label="Pergunta ao Copiloto" />
              <button disabled>Enviar</button>
            </div>
            <p className="copilot-note">A integração com o modelo será conectada no próximo incremento. Os fatos exibidos no produto já são determinísticos.</p>
          </section>
          <aside className="panel context-panel">
            <h2>Contexto da análise</h2>
            <dl>
              <div><dt>Unidade</dt><dd>{data.gymUnit.name}</dd></div>
              <div><dt>Período</dt><dd>Últimos 7 dias</dd></div>
              <div><dt>Comparação</dt><dd>7 dias anteriores</dd></div>
            </dl>
            <Link href="/overview" className="text-action">Voltar para Visão geral</Link>
          </aside>
        </div>
      </div>
    </AppShell>
  );
}
