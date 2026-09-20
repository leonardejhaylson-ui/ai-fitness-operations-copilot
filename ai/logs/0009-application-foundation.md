# AI Log 0009: Application Foundation

- Date: 2026-09-20
- Branch: `codex/application-foundation`
- Scope: application orchestration over the synthetic demo fixture only.

## Objective

Provide one application-facing deterministic snapshot that composes the already approved Synthetic Dataset, Metrics Engine and Insight Engine so upcoming UI work does not couple React pages directly to lower-level tooling/domain internals.

## Implementation

Added `src/modules/application/demo-operations.ts` with a single explicit demo adapter:

`synthetic facts -> calculateMetrics(7/30) -> evaluateInsights -> member application views`

The adapter uses the fixed Golden reference instant `2026-09-19T03:00:00Z`. It exposes the gym unit, both metric periods, deterministic situations and 500 member summaries.

Synthetic behavior labels remain generator/test metadata and are not exposed in the application member view.

## Security boundary

This is NOT the production data-access or authorization boundary. It accepts no tenant input, uses only committed deterministic synthetic generation, performs no database access/writes and exposes no credentials. Real data still requires authenticated server-side tenant resolution and RLS-preserving PostgreSQL access.

No fake login, auth bypass, service role path or browser secret was introduced.

## Tests

Added focused tests for deterministic repeatability, Golden counts, all four situation categories and absence of synthetic labels from application member views.

## Validation status

Local gates pending user execution:

- `pnpm lint`
- `pnpm typecheck`
- `pnpm test`
- `pnpm build`
- `git diff --check`

No dependency, migration, lockfile or normative document changed. Playwright is not required because this increment changes no UI/routes.
