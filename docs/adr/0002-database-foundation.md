# ADR 0002: Local SQL migrations and database access boundaries

- Date: 2026-09-20
- Status: Proposed

## Context

The approved [Database Contract](../normative/06-database-contract-v0.1.md) freezes nine tables, dependency order, composite keys, history and RLS. The [Security Threat Model](../normative/07-security-threat-model-v0.1.md) requires current membership, private conversations and no routine service-role bypass. This increment implements only the database foundation.

## Decision

Translate M01–M13 into ordered SQL migrations, with M14 as transactional SQL integration tests rather than a production migration. Use PostgreSQL 17's built-in UUID generator, text CHECK domains, column-level grants, and triggers for automatic timestamps and the approved historical update restrictions. Enforce snapshot version presence and context/response version agreement without defining an application JSON schema prematurely.

Pin the official Supabase CLI as a development dependency; no ORM or application SDK. Local Data API exposes only an empty `api` schema. Domain tables stay in `public` with RLS and explicit grants independently of API exposure. A narrowly scoped SECURITY DEFINER helper in non-exposed `private` reads current membership for `auth.uid()`, checks account activity, has an empty search path and cannot accept another user ID.

Authenticated access is SELECT plus column-limited own-profile and own-conversation operations. Messages, runs and insights have no end-user write grants or policies. Do not provision speculative orchestration credentials or use service_role for normal requests. The later server integration must provide a server-only, RLS-preserving write boundary with negative integration tests before these use cases become available. No login role, password or remote project is created here.

Run the same SQL tests in local Supabase or a disposable native PostgreSQL cluster. The standalone harness creates only the minimal external Auth table/roles/helper needed to exercise actual PostgreSQL constraints and policies. It does not emulate RLS or claim to validate JWT verification, Auth HTTP flows, PostgREST or Docker lifecycle.

## Consequences

The schema is independently testable without runtime application code. Two clean standalone databases verify reproducibility. Full Supabase validation still requires Docker; a standalone PASS does not replace that gate. Application authorization, snapshot schema validation, request/response semantic checks and evidence validation remain explicit future responsibilities under Contract §6.2 and §10. Privileged maintenance retains its administrative boundary; normal authenticated roles cannot DELETE or TRUNCATE.

This ADR records implementation choices for review and does not change approved artifacts. No additional domain table, status, index or product flow is introduced.

## Validation and review status

PostgreSQL 17.9 validation passed on two clean databases with identical schema dumps and all SQL integration checks. The implementation confirms the decision; no conceptual blocker was found. Status remains Proposed because the [ADR convention](README.md) requires review before acceptance, and no accepting reviewer is recorded. Full Supabase lifecycle validation remains blocked by unavailable Docker/Podman.
