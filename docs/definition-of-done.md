# Initial Definition of Done

A change is done only when:

- it traces to an approved requirement and does not invent behavior;
- it respects documented module, deterministic-computation, AI, tenant, RLS, and secret boundaries;
- relevant code has focused tests, including negative/security cases where applicable;
- `pnpm lint`, `pnpm typecheck`, `pnpm test`, and `pnpm build` pass;
- an applicable critical user-flow change passes `pnpm test:e2e`;
- docs, `.env.example`, and dependency rationale are updated when their contracts change;
- no secrets, generated reports, build products, or production data are committed;
- architectural decisions and material AI work are recorded in `docs/adr/` and `ai/logs/` respectively;
- any normative-document change has explicit human review; and
- the diff is scoped, reviewable, and contains no speculative implementation.
