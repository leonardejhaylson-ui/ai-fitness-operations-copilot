import Link from 'next/link';
import type { ReactNode } from 'react';
import { logout } from '@/app/login/actions';

const NAV = [
  ['/overview', 'Visão geral'],
  ['/attendance', 'Frequência'],
  ['/members', 'Alunos'],
  ['/insights', 'Situações'],
] as const;

export function AppShell({ children, insightCount }: { children: ReactNode; insightCount: number }) {
  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand-block">
          <span className="brand-mark">AF</span>
          <div>
            <strong>Fitness Copilot</strong>
            <small>Operações</small>
          </div>
        </div>

        <nav className="nav-list" aria-label="Navegação principal">
          {NAV.map(([href, label]) => (
            <Link href={href} key={href} className="nav-link">
              <span>{label}</span>
              {href === '/insights' ? <span className="nav-count">{insightCount}</span> : null}
            </Link>
          ))}
          <div className="nav-divider" />
          <Link href="/copilot" className="nav-link">
            <span>Copiloto</span>
          </Link>
        </nav>

        <div className="sidebar-footer">
          <div className="demo-status"><span className="status-dot" /><span>Dados sintéticos · demo</span></div>
          <form action={logout}><button className="logout-button" type="submit">Sair</button></form>
        </div>
      </aside>

      <main className="app-main">{children}</main>
    </div>
  );
}
