# AI Log 0001: Repository Bootstrap

- **Date:** 2026-09-19
- **Status:** Bootstrap committed; executable validation blocked by registry policy

## Objective

Create a clean, documented, testable, agent-friendly repository foundation without implementing business capabilities.

## Prompt/task

Bootstrap the approved Next.js/React/TypeScript/App Router/Tailwind/pnpm stack; configure lint, typecheck, Vitest, Testing Library and Playwright; document architecture, security and Definition of Done; preserve normative artifacts; and validate the foundation. Explicitly exclude database, Supabase/LLM integrations, datasets and product features.

## Plan

1. Inspect repository and applicable agent instructions.
2. Establish minimal application and tooling configuration.
3. Add governance, normative-document locations, ADR and AI audit trail.
4. Install and execute all required quality gates.
5. Correct failures, then commit and open a PR.

## Files created/changed

- Tooling: `package.json`, `pnpm-workspace.yaml`, TypeScript, Next.js, PostCSS/Tailwind, ESLint, Vitest and Playwright configuration.
- Application: minimal `src/app/` shell and one bootstrap-only component/test.
- Tests: Testing Library setup and one Playwright smoke test.
- Governance: `AGENTS.md`, `README.md`, architecture/security/DoD docs, ADR 0001, and seven normative import notices.
- Operations: `.gitignore` and secret-free `.env.example`.

## Decisions

- Use a single package and create no speculative module directories.
- Use Tailwind 4 through `@tailwindcss/postcss`, matching the selected framework setup.
- Keep one component test and one browser smoke test; no broad E2E suite.
- Do not add Supabase or OpenAI SDKs before an approved integration has immediate use.
- Represent unavailable approved artifacts with explicit notices rather than invent their content.
- Do not create empty `ai/reviews/` or `ai/skills/` directories.

## Dependencies added and rationale

| Group | Problem solved / why now | Native alternative | Impact and maintenance |
| --- | --- | --- | --- |
| `next`, `react`, `react-dom` | Required runtime and approved delivery stack | None within the approved stack | Core framework upgrades and React compatibility must be maintained |
| `typescript`, React/Node type packages | Strict compile-time checks needed now | JavaScript/JSDoc lacks the approved TS contract | Dev-only compiler/types require version alignment |
| `tailwindcss`, `@tailwindcss/postcss` | Approved styling tool and build integration | Plain CSS is native, but would omit the approved stack | Build-time packages; follow Tailwind major-version migrations |
| `eslint`, `eslint-config-next` | Framework-aware static analysis | TypeScript alone does not cover lint/accessibility/framework rules | Dev-only; keep aligned with Next.js |
| `vitest`, `jsdom`, Testing Library/jest-dom | Fast unit/component behavior tests required now | Node test runner lacks turnkey jsdom/React queries | Dev-only test surface; avoid implementation-detail assertions |
| `@playwright/test` | Required real-browser smoke validation | Manual browser checks are not repeatable | Browser binary/download and periodic version updates |

No runtime provider SDK was added.

## Tests executed

| Command | Result |
| --- | --- |
| `pnpm install` | Blocked: registry returned HTTP 403 before any dependency could be installed |
| `pnpm lint` | Blocked because `node_modules` is unavailable |
| `pnpm typecheck` | Blocked because framework/test packages and their types are unavailable |
| `pnpm test` | Blocked because Vitest is unavailable |
| `pnpm build` | Blocked because Next.js is unavailable |
| `pnpm test:e2e` | Blocked because Playwright is unavailable |
| `git diff --check` | Passed |

The required checks were attempted rather than represented as successful. They must be rerun after registry access is restored and a lockfile is generated.

## Problems found

- The seven approved artifacts were absent, so faithful content could not be placed in the repository. Controlled placeholders and an import procedure were added.
- Registry metadata and package requests returned HTTP 403. Consequently no `pnpm-lock.yaml` or `node_modules` could be generated, executable checks could not reach project code, and a running-app screenshot could not be captured.

## Result

The scoped source/configuration/documentation foundation is complete. Dependency installation and all dependency-backed validation remain an explicit environment-blocked follow-up; they are not claimed as passing.
