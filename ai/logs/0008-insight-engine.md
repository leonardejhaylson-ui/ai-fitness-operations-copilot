# AI Log 0008: Deterministic Insight Engine

- Date: 2026-09-20.
- Branch: `codex/insight-engine`.
- Scope: deterministic Rule Set v0.1 only. No database persistence, application auth, routes/UI, Copilot/OpenAI, deployment, migrations or normative edits.

## Sources

Implemented from the approved Architecture v0.1, Data Model & Synthetic Dataset Specification v0.1 §§33–42, UI Screen Specification v0.1 Severity Mapping, AGENTS.md and the merged Metrics Engine contract.

## Design

The engine consumes both 7-day and 30-day `MetricsResult` objects for the same authorized GymUnit/reference plus current member status. It does not query storage or authorize a caller.

- 7-day metrics: ATTENDANCE_DROP and hourly access-flow change.
- 30-day metrics: MEMBER_FREQUENCY_DROP and PROLONGED_ABSENCE.
- Rule version: `MVP_RULES_V1`.
- Evidence schema: `insight-evidence-v1`.
- Internal legacy enum `UNUSUALLY_LOW_OCCUPANCY` is retained for database compatibility; evidence terminology is access flow, not simultaneous occupancy.
- No INFO-producing independent rules exist in v0.1.

## Frozen thresholds and severity

- ATTENDANCE_DROP: <= -10% WARNING; <= -20% HIGH.
- MEMBER_FREQUENCY_DROP: <= -40%, reference >= 4 accesses, absolute drop >= 2; <= -60% HIGH.
- PROLONGED_ABSENCE: ACTIVE, >= 10 days, previous 30-day weekly frequency >= 1; >= 21 days HIGH.
- UNUSUALLY_LOW_OCCUPANCY: per-hour flow <= -25%, previous share >= 5%, previous count >= 20; <= -40% HIGH.

Exact-threshold values belong to the higher applicable severity, matching the UI Screen Specification.

## Integrity boundaries

The evaluator rejects mixed units, timezones/reference instants, duplicate status rows and missing member status data. Metrics remain the factual input; Insight Engine applies rules only. It never invents causes, churn prediction or occupancy/presence.

Candidates contain type, severity, subject, current/comparison periods, rule code/version and a versioned evidence snapshot. Persistence into `operational_insights` remains a future application-layer concern so current state stays reproducible from facts + metrics + rules.

## Tests prepared

Focused Vitest coverage includes threshold boundaries, minimum baselines, absolute-drop protection, active-member requirement, historical-frequency protection, high-severity boundaries, low-volume hourly false-positive protection, mixed-context rejection and Golden Dataset integration.

Golden integration is designed to verify the four approved candidate types and known declining/absent member cohorts without relying on synthetic profile labels in production code.

## Validation status

Implementation and tests were created directly through the authenticated GitHub connector while local Codex quota was unavailable.

Local quality gates are therefore **PENDING USER EXECUTION**:

- `pnpm lint`
- `pnpm typecheck`
- `pnpm test`
- `pnpm test:data`
- `pnpm build`
- `git diff --check`

No dependency or lockfile change was made. Playwright is NOT REQUIRED because no UI/route/browser behavior changed.

Do not merge until the local gates are reported and any real failures are corrected.
