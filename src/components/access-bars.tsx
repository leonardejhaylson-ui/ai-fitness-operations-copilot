export function AccessBars({ values, labels }: { values: readonly number[]; labels: readonly string[] }) {
  const max = Math.max(...values, 1);
  return (
    <div className="bar-chart" aria-label="Distribuição de acessos">
      {values.map((value, index) => (
        <div className="bar-column" key={labels[index] ?? index}>
          <div className="bar-track" title={`${labels[index]}: ${value} acessos`}>
            <div className="bar-fill" style={{ height: `${Math.max(4, (value / max) * 100)}%` }} />
          </div>
          <span>{labels[index]}</span>
          <small>{value}</small>
        </div>
      ))}
    </div>
  );
}
