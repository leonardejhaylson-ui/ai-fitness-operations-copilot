# AI Fitness Operations Copilot

AI Fitness Operations Copilot is a synthetic-data operational intelligence demo for gym managers. Its core rule is:

> **The software calculates facts; AI interprets facts.**

The product demonstrates an AI-native delivery workflow and a deterministic product architecture: synthetic operational facts feed a Metrics Engine, deterministic rules generate situations, and the Copilot receives only curated evidence-backed context.

## Current MVP

Implemented:

- Next.js 15.5.7 + React 19 + strict TypeScript
- PostgreSQL/Supabase database contract with 9 approved tables, tenant-safe keys and RLS
- deterministic synthetic dataset: 500 active members and ~33k access records
- deterministic Metrics Engine for 7/30-day comparisons
- deterministic Insight Engine with versioned thresholds/severity
- operational UI: Visão geral, Frequência, Alunos, Situações and Copiloto
- Supabase Auth SSR login/logout and protected operational routes
- OpenAI Copilot through a server-only Responses API gateway
- strict structured output and backend evidence-ID validation
- Vitest + Playwright coverage
- browser security headers and best-effort Copilot throttling

The demonstration data remains synthetic. Authentication can be real, but the current operational UI intentionally reads the deterministic demo adapter rather than claiming a finished production tenant database integration.

## Demo flow

`Login -> Visão geral -> Situação -> Frequência/Aluno -> Copiloto -> resposta com evidências`

Useful demo questions:

- O que mudou nos últimos 7 dias?
- Onde a frequência mais mudou?
- Quais alunos apresentam redução relevante?
- Quais situações estão ativas?

The Copilot must not invent a cause when the available data only shows correlation or concentration of change.

## Environment

Copy the example file:

```bash
cp .env.example .env.local
```

Configure:

```text
SUPABASE_URL=
SUPABASE_ANON_KEY=
OPENAI_API_KEY=
OPENAI_MODEL=
```

`OPENAI_MODEL` is optional; the application has a server-side default. Never commit real credentials.

## Local development

Requires Node.js 20.9+ and pnpm 10.28.1.

```bash
corepack enable
corepack prepare pnpm@10.28.1 --activate
pnpm install --frozen-lockfile
pnpm dev
```

Quality gates:

```bash
pnpm lint
pnpm typecheck
pnpm test
pnpm test:data
pnpm build
pnpm test:e2e
git diff --check
```

## Deployment target

Vercel is the intended MVP deployment target. Add the server environment variables in Vercel rather than committing a local env file.

For Supabase Auth, create a demo user in the Supabase project and configure the project/site redirect settings for the final Vercel domain.

## Architecture

```text
Synthetic operational facts
        |
        v
Deterministic Metrics Engine
        |
        v
Deterministic Insight Engine
        |
        +------> Operational UI
        |
        v
AI Context Builder
        |
        v
OpenAI Responses API
        |
        v
Structured output
        |
        v
Evidence Validator
        |
        v
Copilot UI
```

The LLM has no unrestricted SQL, service-role credential, authorization responsibility or tenant-selection authority.

## Repository map

- `docs/normative/` — seven approved source-of-truth specifications
- `supabase/` — migrations and database contract tests
- `scripts/data/` — deterministic synthetic dataset and Golden fixtures
- `src/modules/metrics/` — deterministic Metrics Engine
- `src/modules/insights/` — deterministic Insight Engine
- `src/modules/application/` — application-facing demo orchestration
- `src/modules/copilot/` — AI context/gateway/evidence validation
- `src/app/` — Next.js routes and operational screens
- `ai/logs/` — auditable AI-native implementation trail

See `AGENTS.md`, `docs/security-rules.md`, `docs/definition-of-done.md` and the normative specifications for implementation constraints.
