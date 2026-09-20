import Link from 'next/link';
import type { InsightCandidate } from '@/modules/insights';
import { formatPercent, insightDestination, insightSummary, insightTitle } from '@/modules/presentation/format';

export function InsightList({ insights, limit }: { insights: readonly InsightCandidate[]; limit?: number }) {
  const ordered = [...insights].sort((a, b) => {
    if (a.severity !== b.severity) return a.severity === 'HIGH' ? -1 : 1;
    return a.type.localeCompare(b.type);
  });
  const rows = limit ? ordered.slice(0, limit) : ordered;

  return (
    <div className="insight-list">
      {rows.map((insight, index) => (
        <article className="insight-row" key={`${insight.type}-${insight.subject_id ?? index}-${index}`}>
          <div className={`severity-badge ${insight.severity === 'HIGH' ? 'severity-high' : 'severity-warning'}`}>
            {insight.severity === 'HIGH' ? 'Alta' : 'Atenção'}
          </div>
          <div className="insight-body">
            <h3>{insightTitle(insight)}</h3>
            <p>{insightSummary(insight)}</p>
            {typeof insight.evidence_snapshot.change_percentage === 'number' ? (
              <span className="insight-evidence">{formatPercent(insight.evidence_snapshot.change_percentage)}</span>
            ) : null}
          </div>
          <Link href={insightDestination(insight)} className="text-action">Investigar</Link>
        </article>
      ))}
    </div>
  );
}
