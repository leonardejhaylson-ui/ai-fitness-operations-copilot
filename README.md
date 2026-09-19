# AI Fitness Operations Copilot

AI Fitness Operations Copilot is intended to support fitness-operation decisions with deterministic, evidence-backed facts and AI-assisted interpretation. Its central rule is: **the software calculates facts; AI interprets facts**.

## AI-native demonstration

The repository is also an auditable demonstration of AI-native delivery: approved inputs remain visible, durable decisions are ADRs, and material AI work is logged under `ai/`. AI output does not replace deterministic computation, evidence validation, security controls, or human review.

## Current status

This is **repository bootstrap only**. It provides a minimal Next.js shell and test/tooling foundation. It does not implement authentication, Supabase integration, database schema or migrations, RLS, synthetic data, business metrics, insights, dashboards, Copilot behavior, or LLM integration.

The seven approved artifacts were named but their contents were not supplied with the bootstrap task. Their repository documents therefore carry explicit import notices and must be replaced with the approved verbatim content before they can guide feature implementation. See [`docs/normative/README.md`](docs/normative/README.md).

## Stack

- Next.js App Router, React, and strict TypeScript
- Tailwind CSS 4 through its PostCSS plugin
- pnpm
- PostgreSQL/Supabase and Supabase Auth (approved, not integrated yet)
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

## Repository map

- `src/app/`: Next.js delivery shell
- `src/components/`: currently only the bootstrap status component
- `tests/`: shared unit setup and minimal E2E smoke coverage
- `docs/normative/`: controlled copies/placeholders for approved artifacts
- `docs/adr/`: durable architectural decisions
- `ai/logs/`: AI-native work audit trail
- `AGENTS.md`: mandatory operating contract for contributors and agents

No speculative domain directory is created until it has real implementation content.
