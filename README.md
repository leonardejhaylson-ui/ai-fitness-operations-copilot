# AI Fitness Operations Copilot

AI Fitness Operations Copilot is intended to support fitness-operation decisions with deterministic, evidence-backed facts and AI-assisted interpretation. Its central rule is: **the software calculates facts; AI interprets facts**.

## AI-native demonstration

The repository is also an auditable demonstration of AI-native delivery: approved inputs remain visible, durable decisions are ADRs, and material AI work is logged under `ai/`. AI output does not replace deterministic computation, evidence validation, security controls, or human review.

## Current status

The repository contains the Next.js tooling foundation and the **local database foundation**: nine contract-defined tables, ordered PostgreSQL migrations, constraints, historical lifecycle guards, RLS, and database integration tests. Application authentication, database adapters, synthetic data, engines, product screens and AI integration remain future increments.

See [local database setup and validation](docs/database-local.md) for Supabase and disposable PostgreSQL commands and their validation boundaries.

The seven approved v0.1 normative artifacts are now imported under [`docs/normative/`](docs/normative/) and are the project sources of truth for subsequent implementation work.

## Stack

- Next.js App Router, React, and strict TypeScript
- Tailwind CSS 4 through its PostCSS plugin
- pnpm
- PostgreSQL 17 / Supabase local CLI (database foundation); Supabase Auth application integration pending
- Vitest, Testing Library, and Playwright
- Vercel deployment target (not configured in this phase)

## Architecture at a glance

The target is a modular monolith with Next.js as the delivery layer and PostgreSQL as source of truth. Transport handlers remain thin; deterministic Metrics and Insight Engines own calculations. AI integration flows through an AI Context Builder, LLM Gateway, and Evidence Validator. The LLM receives curated facts and never free-form database access. Tenant checks at application boundaries and PostgreSQL RLS provide layered isolation.

See [`docs/architecture-conventions.md`](docs/architecture-conventions.md), [`docs/security-rules.md`](docs/security-rules.md), and [`docs/definition-of-done.md`](docs/definition-of-done.md).

## Prerequisites and installation

- Node.js 20.9 or newer
- pnpm 10.28.1 (use Corepack to activate the version declared in `package.json`)

```bash
corepack enable
pnpm install --frozen-lockfile
cp .env.example .env.local
pnpm exec playwright install chromium
```

The example environment file contains no credentials. The current shell needs none.

## Development commands

| Command | Purpose |
| --- | --- |
| `pnpm dev` | Run the local development server |
| `pnpm build` | Produce a production Next.js build |
| `pnpm start` | Serve the production build |
| `pnpm lint` | Run ESLint |
| `pnpm typecheck` | Run strict TypeScript checks without emitting files |
| `pnpm test` | Run unit/component tests once |
| `pnpm test:watch` | Run Vitest in watch mode |
| `pnpm test:e2e` | Run the minimal Playwright smoke test |
| `pnpm db:start` / `pnpm db:stop` | Start/stop local Supabase (Docker required) |
| `pnpm db:reset` | Rebuild the local database without seed |
| `pnpm db:lint` | Lint the local Supabase database |
| `pnpm test:db` | Run SQL integration tests in the local Supabase container |
| `pnpm test:db:standalone` | Run migrations/tests twice in disposable PostgreSQL 17 |

## Repository map

- `src/app/`: Next.js delivery shell
- `src/components/`: currently only the bootstrap status component
- `tests/`: shared unit setup and minimal E2E smoke coverage
- `supabase/`: local configuration, M01–M13 migrations and M14 SQL tests
- `scripts/database/`: local-only database validation harnesses
- `docs/normative/`: controlled copies of the seven approved v0.1 normative artifacts
- `docs/adr/`: durable architectural decisions
- `ai/logs/`: AI-native work audit trail
- `AGENTS.md`: mandatory operating contract for contributors and agents

No speculative domain directory is created until it has real implementation content.
