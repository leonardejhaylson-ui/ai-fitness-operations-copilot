# AI Log 0006: Deterministic Synthetic Dataset

- Date: 2026-09-20.
- Task: implement the approved MVP synthetic dataset; commit and open a PR to main without merging.
- Branch: `codex/synthetic-dataset`, created from clean main after fetch and fast-forward verification (`ffb3c7a`, merged Data Foundation PR #5).
- Scope: development/test tooling only. No Metrics Engine, Insight Engine, authentication, UI, routes, Copilot, OpenAI, deployment or GitHub Actions. No normative artifact or migration changes.

## Sources and plan

Read AGENTS.md, Data Model & Synthetic Dataset Specification v0.1 (especially §§11–22, 40–42), Database Contract v0.1, Security Threat Model v0.1, docs/database-local.md, ai/logs/0005-data-foundation.md and docs/definition-of-done.md. Database/security rules take precedence over older illustrative schema snippets.

1. Update main and create the requested branch.
2. Implement fixed configuration, PRNG, IDs, member schedules, independent scenario overlays and validation in scripts/data.
3. Keep operational exports separate from profile/control metadata; pin a Golden manifest.
4. Add an explicit local administrative load path, with transactional idempotency and refusal to rewrite facts.
5. Prove Golden properties, negative tenant/history cases, and real PostgreSQL loading; run all required checks.
6. Record results, commit, push, and open the requested PR without merge.

## Configuration and implementation decisions

- Dataset version: `fitness-demo-v1`.
- Seed: `20260919` (unsigned 32-bit seeded PRNG, Mulberry32 algorithm).
- Reference date: `2026-09-19`, exclusive local midnight in `America/Sao_Paulo` (`2026-09-19T03:00:00Z`). The approved specification requires a fixed value without providing one. This is an explicit fixture implementation choice, independent of the system clock.
- History: 180 full local days, `[2026-03-23, 2026-09-19)`.
- Main gym: `f17e5500-0000-5000-8000-000000000001`.
- IDs: SHA-256 namespaced by version/seed/unit/member/day, encoded as UUIDv8. Scenario overlays preserve original access IDs and facts. No random UUID/default timestamp is used in the seed.
- Time conversion: fixed UTC−03 for the deliberately bounded modern Sao Paulo dataset. Explicit alternate reference dates are supported only in 2020–2026, ensuring the entire 180-day window is after Brazilian DST ended. Unsupported eras are rejected; this is not a general timezone adapter.
- No architectural boundary changes or new runtime subsystem; implementation decisions are recorded here instead of adding a speculative ADR.

## Profiles, schedules and anomalies

Exactly 500 ACTIVE members: 75 frequent, 175 regular, 75 low-frequency, 75 irregular, 40 declining, 25 apparent abandonment, 35 prolonged absence. `joined_at` and creation timestamps predate the history window. No current status is used to retroactively alter facts.

Each member has a deterministic weekly schedule sampled without replacement, at most one valid visit per local day. Weekday weights follow the approved conceptual multipliers; weekends are lighter. Hour bands include morning, midday, evening peaks and smaller intermediate/late bands. Small seeded natural variation and seasonal factors sit below controlled anomalies. Fifty frequent weekday-morning members provide a stable control. No simultaneous-presence/occupancy data is generated.

Overlays are independently selectable through the tooling API: baseline, attendance, weekday, evening, member, absence and combined demo. Overlays remove candidate visits before persistence. Progressive decline has four decreasing weekly retention levels; apparent abandonment has no final-21-day visits; prolonged absence removes the final 10–25 days of candidates. Exact final gaps can be longer due to the member's weekly visit spacing. These are behavioral test labels, never cancellation predictions.

Twelve explicit VOIDED duplicate fixtures from the oldest week preserve the original visit, creation time and a later void timestamp. They remain stored but are excluded from every Golden raw count.

Profile labels and morning cohort IDs are in generator/test metadata only. SQL and operational JSON contain precisely the real columns from the Database Contract. No user/auth membership, insight, metric, conversation or AI rows are seeded.

## Golden results

The committed `scripts/data/golden.json` pins the complete generated fixture fingerprint, raw counts, expected scenario descriptions, member IDs and expected peak bands. It is not regenerated automatically by tests.

| Property | Result |
| --- | --- |
| Members | 500 |
| Access records | 33,249 |
| VALID / VOIDED | 33,237 / 12 |
| Final / previous 7 days | 928 / 1,087 (−14.63%) |
| Final / previous 30 days | 4,853 / 5,616 |
| Tuesday, prior → recent | 177 → 141 (−20.34%) |
| Wednesday, prior → recent | 200 → 158 (−21.00%) |
| 18:00–20:00, prior → recent | 181 → 108 (−40.33%) |
| 06:00–09:00, prior → recent | 401 → 406 (+1.25%) |
| Dedicated morning cohort | identical equivalent-week counts |
| Full fixture SHA-256 | `673aebae24cd4c4636018b574871455e54b8bca1f2f6bd5bf98a296c86cd67fb` |

A01–A10 have explicit raw-property tests: overall decline, Tuesday/Wednesday concentration, evening decline, progressive-member reduction, active members absent >=10 days with prior regular history, stable mornings, lighter weekends, variable irregular weeks with stable longer totals, and stable aggregate baseline. Isolated attendance is approximately −12%, isolated evening approximately −29%; combined overlays can produce stronger localized effects. The member group declines >=40% in the final week; every declining member has fewer recent-30-day visits than in the prior 30 days.

No final metric/rule implementation was introduced. Future insight candidates are manifest expectations only. Exact insight output/severity and absence of false positives require the future engines; the raw fixture alone cannot certify those classifications.

## Loading, integrity and security

- Generated SQL and JSON are ignored artifacts under node_modules/.cache, not migrations or committed bulk data.
- `pnpm data:load --local` requires an explicit target and pins the fixed project container through `/var/run/docker.sock`, ignoring remote Docker context/host settings. It accepts no arbitrary database URL or browser input.
- Administrative seed validates exact column allowlists, tenant associations, IDs, counts, history window, member lifecycle and VOIDED timestamps before rendering SQL. SQL string values are quoted; table/column names are fixed.
- One transaction and advisory lock; parent-before-child insertion; existing identical rows remain untouched. Existing differing rows or extra tenant rows abort the load. No UPDATE/DELETE/TRUNCATE, trigger disablement, RLS bypass setting, schema change or runtime service-role integration.
- Standalone integration reuses the existing PostgreSQL 17 private Unix-socket harness. It applies all migrations and foundation suites to two clean databases, seeds twice per database, compares every persisted field across repetitions/databases, checks Golden counts and actual authenticated-role tenant denial, and rejects a reseed after a legitimate VALID → VOIDED correction without changing that history.
- A second tenant and authenticated users are rollback-only SQL test fixtures, not part of the demo dataset. Loader tests use fake executables and no database/network access.

## Dependencies and environment

No dependencies added, no lockfile change, no global installation. Existing TypeScript compiles tooling to ignored CommonJS output; Node crypto handles IDs/fingerprints. No Faker, date package, ORM or PRNG package. Reused Node 24.15.0, pnpm 10.28.1 and the prior temporary PostgreSQL 17.9 binaries.

The sandbox could not create a bwrap namespace; approved command escalation was used without changing host configuration. Docker and Podman remain unavailable. The local Supabase loader was attempted and blocked by missing Docker. Standalone validation independently proves relational/tenant/history integrity, not full Supabase Auth, JWT validation, PostgREST or platform lifecycle compatibility.

Initial unit-test attempts encountered a 5-second timeout due to redundant full-dataset generation and then CPU contention while the Next build was running. Removed redundant generation and excessive per-row assertion overhead; ran final checks sequentially. Golden behavioral assertions themselves passed throughout. No timeout limit or assertion was weakened. Build-generated next-env.d.ts drift was restored.

## Checks and publication

| Check | Status | Evidence |
| --- | --- | --- |
| pnpm install --frozen-lockfile | PASS | Lockfile up to date; no dependency changes. |
| pnpm lint | PASS | Final exit 0. |
| pnpm typecheck | PASS | Final exit 0, strict TypeScript including tooling/tests. |
| pnpm test | PASS | 29 tests, three files. |
| pnpm test:data | PASS | 28 tests, two files; explicit Golden and loader checks. |
| pnpm build | PASS | Production compilation/type validation and four static pages completed, exit 0. |
| pnpm test:data:standalone | PASS | PostgreSQL 17.9; foundation suites on two clean databases; four seed loads; field-for-field repeatability; all Golden/FK/RLS/void checks; drift refused; cleanup completed. |
| git diff --check | PASS | No whitespace errors. |
| Full Supabase local load | BLOCKED | Docker/Podman absent; independently validated on standalone PostgreSQL. |
| Playwright | NOT REQUIRED | No UI, route or browser behavior changed; explicit task exemption. |
| Scope review | PASS | No normative document, migration, src application file or lockfile change; no added dependency, generated bulk artifact or credential. |

Result: requested deterministic dataset and standalone integration PASS. Remaining limitations are full Supabase runtime validation, bounded modern Sao Paulo conversion, standard local Docker socket requirement, and future-engine verification of exact insight outputs/false positives. The initial loader-test ProcessEnv typing error was corrected by supplying NODE_ENV=test, then all checks passed.

Publication: local HTTPS git push was blocked because no credential helper was configured. The authenticated GitHub connector is used to publish the same reviewed file tree as `feat: implement deterministic synthetic dataset` on `codex/synthetic-dataset`, then open `feat: implement synthetic dataset` against main without merging. Local and remote tree equality is checked before aligning the local branch. Final commit and PR identifiers are reported in the completion response.
