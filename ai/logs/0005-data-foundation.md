# AI Log 0005: Data Foundation

- Date: 2026-09-20
- Scope: local database foundation only; no dataset, engines, UI, AI integration, remote project, production configuration or GitHub Actions.
- Branch: `codex/data-foundation`, created from updated clean `main` at `2da9a5d2d65eca13a5f44aaa90d013d7ec5ae7e5`.
- Status: validation in progress; full Supabase runtime BLOCKED by missing Docker/Podman.

## Objective and sources

Implement the nine approved tables, constraints, composite FKs, indexes, lifecycle integrity, minimal RLS and real database tests. Read AGENTS.md, Architecture v0.1, Data Model & Synthetic Dataset Specification v0.1, Database Contract v0.1, Security Threat Model v0.1, docs/security-rules.md, docs/definition-of-done.md, ai/logs/0004-local-foundation-validation.md and the ADR convention. Database Contract takes precedence over earlier illustrative index/schema proposals; no normative document was changed.

Consulted official Supabase CLI installation/configuration/migration documentation and the Supabase Auth auth.uid migration. External tool documentation informed local tooling only, not domain requirements.

## Plan and changes

1. Verify clean state, update main, create requested branch.
2. Translate the contract in dependency order M01–M13.
3. Add M14 as rollback-only integration tests, not a fixture migration.
4. Validate schema/constraints/history/RLS in real PostgreSQL, then application gates.
5. Record security review and limitations, commit, publish branch and open PR without merging.

Migrations in `supabase/migrations/20260920000001_*` through `20260920000013_*`:

- M01: built-in UUID capability, private updated_at helper, empty API schema, restrictive defaults.
- M02–M05: app_users, gym_units, user_gym_units, members.
- M06: access_records, composite member/unit FK and one-way VOIDED correction.
- M07: operational_insights, member/unit FK, periods/comparisons, versioned JSON, immutable snapshot/resolution guard.
- M08–M09: ai_conversations and ai_messages, tenant/owner candidate keys, append-only message guard.
- M10: full ai_runs audit columns, tenant/owner/request/response FKs, snapshots/version checks, status consistency and transition/immutability guard.
- M11: reverse message/run composite FK completes the circular dependency.
- M12: only nine contract-approved secondary indexes.
- M13: explicit role/column grants, RLS on all nine tables and owner/current-membership policies.

Tests: `supabase/tests/database/001_foundation.sql` (allow/deny and integrity/lifecycle) and `002_schema_contract.sql` (all 93 expected contract columns, types, nullability, defaults and security metadata). Test fixtures are small and transactionally rolled back; they are not the synthetic operational dataset.

Other files: local Supabase config/.gitignore; three scripts/database files; package scripts and lockfile; README; docs/database-local.md; proposed ADR 0002; security review evidence; this log.

## Decisions and dependencies

- Only new direct dependency: development-only official `supabase@2.117.0`, exact pinned with lockfile, for local orchestration/migrations/lint. No ORM, runtime SDK or global installation. Reviewed package manifest: platform binaries are optional dependencies; no install/postinstall script and no build-script allowlist change. No CLI imports enter application bundles.
- PostgreSQL 17 built-in gen_random_uuid requires no UUID extension.
- SQL triggers enforce approved mutation restrictions without domain orchestration code.
- Private SECURITY DEFINER helper accepts only unit ID and resolves auth.uid internally; reads current membership and active/nondeleted application account. No arbitrary user parameter, dynamic SQL or JSON-based authorization.
- Column grants limit own profile and conversation edits. No authenticated writes to messages/runs/insights; future server orchestration must establish an RLS-preserving server-only boundary. No service-role request path or speculative login credentials were introduced.
- Empty `api` is the only locally exposed Data API schema; public domain relations have independent grants/RLS. No additional domain table.
- M14 is executable integration coverage, not a production migration. Standalone testing uses a real PostgreSQL engine with minimal external Auth fixtures and actual non-BYPASSRLS roles; it does not validate JWT signatures, Auth HTTP, PostgREST or full Supabase services.
- ADR 0002 remains Proposed for reviewer consideration; approved artifacts remain untouched.

## Environment and problems

The execution sandbox cannot create a namespace (bwrap); commands used approved escalation without changing host settings. Node v24.15.0 and pnpm 10.28.1 from the prior temporary installation were reused. Docker, Podman and native PostgreSQL were absent both from this environment and the host checks.

Installed the pinned CLI locally. `pnpm db:start` parsed configuration but failed because Docker/Podman is absent. Its deprecated `[inbucket]` warning was corrected to `[local_smtp]`. `pnpm db:lint` was attempted with public/private schemas and failed to connect to local port 54322 because the stack is not running. No remote alternative was provisioned.

To avoid mocked RLS or stopping at a tooling limitation, downloaded official PostgreSQL 17.9 source to ignored node_modules/.cache, verified its published SHA-256, compiled and installed there without global changes. The committed standalone harness accepts PostgreSQL 17 binaries on PATH, builds a fresh private Unix-socket cluster, applies migrations twice to separate empty databases, runs the same SQL tests, compares schema dumps and cleans up. The temporary compiler/source/binaries are not project dependencies or committed artifacts.

Existing Next.js/ESLint deprecation and security notices remain the pre-existing follow-up recorded in log 0004; this increment does not upgrade unrelated dependencies. Playwright is not required: no application code, routes, UI, authentication journey or browser dependency changed.

## Validation and publication

Final results and any test-driven corrections are recorded below after execution.
