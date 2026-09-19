# Agent Operating Contract

These instructions apply to the entire repository.

## Sources of truth and precedence

Use the approved documents in `docs/normative/`. Apply them in this order when guidance conflicts:

1. Security Threat Model v0.1 and Database Contract v0.1 for security/data invariants in their respective domains.
2. Architecture v0.1 and Product Specification v0.1.
3. Data Model & Synthetic Dataset Specification v0.1.
4. Product UX, Design Direction & Design System v0.1.
5. UI Screen Specification v0.1.
6. Accepted ADRs, which may clarify but must not silently override an approved artifact.

Stop and request review when two approved artifacts genuinely conflict. Never invent missing requirements. Treat the imported documents in `docs/normative/` as the approved v0.1 sources of truth.

## Architecture and module boundaries

- Build a modular monolith delivered by Next.js App Router.
- Keep route handlers and Server Actions thin. Domain rules belong in explicit application/domain modules, not transport code or React components.
- PostgreSQL/Supabase is the source of truth.
- Metrics Engine and Insight Engine must be deterministic.
- The AI path is AI Context Builder -> LLM Gateway -> Evidence Validator. The software calculates facts; AI interprets facts.
- The LLM must never generate or execute free-form SQL.
- Keep UI, application orchestration, deterministic domain logic, infrastructure adapters, and AI integration separated. Add directories only with working content.

## Security invariants

- Every tenant-owned access must derive and enforce tenant context server-side. Never trust a browser-provided tenant identifier, and test cross-tenant denial.
- RLS is mandatory defense in depth, not a replacement for application authorization. Do not weaken/bypass it in product paths.
- Never expose secrets, service-role credentials, or privileged tokens in browser bundles. `NEXT_PUBLIC_` values are public.
- Do not commit secrets or production data. Use `.env.example` with empty placeholders.
- Do not modify the Database Contract or Security Threat Model without explicit human review and a recorded decision.

## Product and testing rules

- Do not create product UI components or screens outside the UI Screen Specification without documenting the reason and obtaining review.
- Every change must include tests at the lowest useful level. Security and tenant boundaries require negative tests. Keep E2E focused on critical journeys.
- Before completion, run `pnpm lint`, `pnpm typecheck`, `pnpm test`, `pnpm build`, and applicable `pnpm test:e2e` checks.
- Keep strict TypeScript; avoid untyped boundary data. Do not place domain calculations in prompts.

## Decisions and AI-native audit

- Record lasting architectural decisions as sequential files in `docs/adr/` using the ADR template/convention documented there.
- Record material agent sessions sequentially in `ai/logs/`, including task, plan, changes, decisions, dependencies, checks, problems, and result.
- Put review evidence in `ai/reviews/` and reusable local skills in `ai/skills/` only when real content exists; do not create empty directories.
- A change to a normative artifact must identify the approving reviewer and must not be disguised as an ordinary implementation edit.
