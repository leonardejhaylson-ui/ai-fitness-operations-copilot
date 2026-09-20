import Link from 'next/link';
import { AppShell } from '@/components/app-shell';
import { loadDemoOperations } from '@/modules/application/demo-operations';
import { formatDate, formatDecimal, formatPercent } from '@/modules/presentation/format';

export default function MembersPage() {
  const data = loadDemoOperations();
  const frequencyMembers = new Set(data.insights.filter((i) => i.type === 'MEMBER_FREQUENCY_DROP' && i.subject_id).map((i) => i.subject_id));
  const absenceMembers = new Set(data.insights.filter((i) => i.type === 'PROLONGED_ABSENCE' && i.subject_id).map((i) => i.subject_id));

  return (
    <AppShell insightCount={data.insights.length}>
      <div className="page">
        <header className="page-header">
          <div>
            <span className="eyebrow">{data.gymUnit.name}</span>
            <h1>Alunos</h1>
            <p>500 alunos · ordenação por nome</p>
          </div>
        </header>

        <div className="filters-row">
          <label className="search-field">
            <span>Buscar por nome ou código</span>
            <input placeholder="Buscar por nome ou código" disabled aria-label="Buscar por nome ou código" />
          </label>
          <div className="filter-box"><span>Status</span><strong>Todos</strong></div>
          <div className="filter-box"><span>Situação de frequência</span><strong>Todas</strong></div>
        </div>

        <div className="table-wrap">
          <table className="members-table">
            <thead><tr><th>Aluno</th><th>Status</th><th>Frequência recente</th><th>Variação</th><th>Último acesso</th><th>Situação ativa</th></tr></thead>
            <tbody>
              {data.members.slice().sort((a,b) => a.display_name.localeCompare(b.display_name)).slice(0,25).map((member) => (
                <tr key={member.id}>
                  <td><Link href={`/members/${member.id}`}><strong>{member.display_name}</strong><small>{member.member_code}</small></Link></td>
                  <td>Ativo</td>
                  <td>{formatDecimal(member.current_30d_visits * 7 / 30)} visitas/semana</td>
                  <td>{formatPercent(member.frequency_change_percentage)}</td>
                  <td>{formatDate(member.last_visit_at)}</td>
                  <td>{frequencyMembers.has(member.id) ? 'Redução relevante' : absenceMembers.has(member.id) ? 'Ausência prolongada' : '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="pagination"><span>1–25 de 500</span><div><button disabled>Anterior</button><button>Próxima</button></div></div>
        </div>
      </div>
    </AppShell>
  );
}
