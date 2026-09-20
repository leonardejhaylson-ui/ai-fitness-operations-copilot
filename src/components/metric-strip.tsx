import type { ReactNode } from 'react';

export function MetricStrip({ items }: { items: readonly { label: string; value: ReactNode; meta?: string }[] }) {
  return (
    <section className="metric-strip" aria-label="Métricas principais">
      {items.map((item) => (
        <div className="metric-item" key={item.label}>
          <span className="metric-label">{item.label}</span>
          <strong className="metric-value">{item.value}</strong>
          {item.meta ? <span className="metric-meta">{item.meta}</span> : null}
        </div>
      ))}
    </section>
  );
}
