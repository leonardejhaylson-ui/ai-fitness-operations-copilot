# AI Log 0007: Deterministic Metrics Engine

- Date: 2026-09-20.
- Task: implement the MVP Metrics Engine, commit and open a PR to main without merging.
- Branch: `codex/metrics-engine`, created from clean, fetched, fast-forward-verified main at `68d108c` (Synthetic Dataset merged).
- Scope: pure in-memory metrics and tests. No normative edits, database writes, persistence, Insight Engine, authentication, SDK, UI/routes, Copilot, OpenAI, deployment or Actions.

## Sources and plan

Consulted AGENTS.md, Architecture v0.1, Data Model & Synthetic Dataset Specification v0.1 (especially §§23–32), Database Contract v0.1 (including lifecycle, period and timezone contracts), security rules/threat-model boundaries, definition of done, logs 0005/0006, scripts/data generator/config/validation and Golden manifest.

Plan: update main and branch; establish exact definitions; implement explicit input/result types and pure calculations; test boundaries, negative tenant cases, timezone/DST, member history and Golden fixture; run required gates; record evidence; commit and publish a PR without merge.

## Changes and decisions

`src/modules/metrics` contains public types, period/time conversion, the engine, focused tests and its integration contract. No speculative repository abstraction or new architectural subsystem beyond the approved module. Implementation choices are recorded here; no normative/architectural override or new ADR is required.

- Active snapshot uses `joined_at < end`, null or `deactivated_at >= end`, and null `deleted_at`, exactly as §24. It does not use current status.
- Total accesses includes all VALID facts of the authorized unit within the interval, independently of member current status. VOIDED is ignored throughout.
- Average is visits per active member in that period, without weekly normalization; zero active denominator gives null.
- Current and previous periods are adjacent `[start,end)` and exactly 7 or 30 elapsed 24-hour days each. Caller supplies an explicit ISO reference instant with offset. Golden reference is exclusive `2026-09-19T03:00:00Z`.
- Percentage change is `(current - previous) / previous * 100`. Zero baseline, including 0 → 0, gives null/not comparable. No Infinity, NaN, thresholds or early rounding.
- Native Intl with the unit's IANA timezone derives local day, weekday and hour. No fixed offset. Across DST, equal elapsed periods can have partial local boundary dates. Daily bins include zero counts, weekday bins use Sunday=0, hourly bins use 0–23; repeated local hours accumulate in the same bin.
- Member facts include current/previous visits, weekly-normalized frequencies per §30, frequency change, last visit and local calendar days since last visit. Every supplied member is represented, including no-history and inactive members; no classification occurs.
- Last visit uses the explicit §32 snapshot `occurred_at <= T`, where T is the reference instant. This is separate from exclusive interval counting. An exact-end visit affects last visit but not current total. Calendar date subtraction, not elapsed hours, gives days since visit. No history gives null.
- Output includes unit, timezone, both periods, duration, interval/snapshot semantics and calculation version. Stable member/date ordering; no global clock or mutation.
- Reject mixed tenants, missing member references and duplicate facts. Caller must already authorize the GymUnit server-side and supply complete authorized history. Engine checks do not implement authentication or replace RLS.

## Golden results and tests

Integration generates the existing approved dataset in memory; it does not connect to PostgreSQL/Supabase or reuse generator calculations in the engine. Fixture labels and hard-coded expected values remain test-only.

| Fact | Previous | Current |
| --- | --- | --- |
| 7-day accesses | 1,087 | 928 |
| 30-day accesses | 5,616 | 4,853 |
| Tuesday, 7 days | 177 | 141 |
| Wednesday, 7 days | 200 | 158 |
| 18:00–20:00, 7 days | 181 | 108 |
| 06:00–09:00, 7 days | 401 | 406 |

7-day change ≈ −14.63%; active members 500; average visits 928/500 = 1.856. The fixture's 12 VOIDED rows are excluded; a dedicated in-period VOIDED unit case ensures exclusion is exercised inside analytical windows. Tests cover [start,end) and exact-end snapshot, equal periods, empty baselines, local midnight, DST repeated hour, historical active snapshots, deletion, decline/stability/no recent visit, old history, future accesses, calendar-day gaps, distributions, determinism, order independence and no input mutation. Negative cases cover foreign-unit rows, orphan members, duplicate IDs, invalid dates/offsets/zones and unsupported periods.

## Dependencies, checks and environment

No dependencies or lockfile changes. Uses existing TypeScript, Vitest, native Date/Intl and Node 24.15.0/pnpm 10.28.1 temporary tooling. Initial sandbox invocation failed because bwrap cannot create a namespace; approved escalated commands used without changing host settings. Initial pnpm lookup used the parent directory instead of its bin directory; corrected PATH and reran all gates.

- `pnpm install --frozen-lockfile`: PASS, lockfile unchanged.
- `pnpm lint`: PASS.
- `pnpm typecheck`: PASS.
- `pnpm test`: PASS, 39 tests in four files (10 metrics tests).
- `pnpm test:data`: PASS, 28 tests in two files.
- `pnpm build`: PASS, production compilation/type validation and four static pages completed, exit 0.
- `git diff --check`: PASS; repeated before commit.
- Playwright: NOT REQUIRED by explicit task exemption; no UI/routes changed.
- Database: NOT REQUIRED; pure calculations and real generated in-memory Golden input.

## Limitations and publication

The future application integration must resolve authorization and supply complete history. Truncated history cannot prove a member never visited. ICU/tzdata updates can change historical timezone conversion; reproducibility assumes the same runtime timezone rules. Periods guarantee equal elapsed duration rather than both boundaries being local midnight through DST. No simultaneous occupancy or insight classification is inferred. These semantics are documented in the public module README.

Restore only build-generated next-env.d.ts drift before commit. Publish `feat: implement deterministic metrics engine` and open `feat: implement metrics engine` against main, without merging. If HTTPS push lacks credentials, use the authenticated GitHub connector to publish the identical reviewed tree and verify local/remote tree equality. Publication identifiers are reported in the final response.
