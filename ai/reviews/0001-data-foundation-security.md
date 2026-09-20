# Data foundation security review

Date: 2026-09-20. Scope: migrations, local configuration, SQL tests and test harnesses. Author: implementation agent; this evidence does not substitute for human review.

| Boundary | Implementation and evidence |
| --- | --- |
| service_role | No credentials or normal request integration added. Platform bypass remains administrative; authenticated roles never inherit it. |
| Identity | Membership helper takes only unit UUID; reads auth.uid(), current database membership and account status. Test role has neither superuser nor BYPASSRLS. |
| Tenant FKs | Access/member, insight/member, message/conversation, run/conversation/owner, run/request/response and message/run keys include tenant/conversation dimensions. Negative FK tests run independently of RLS. |
| RLS | All nine tables enabled. Explicit operation-specific policies; no ALL or DELETE policy. Own profile/memberships; tenant reads; AI owner plus current membership. Tests cover same-unit peer privacy and revoked/missing membership. |
| Grants | Broad Supabase defaults revoked from PUBLIC/anon/authenticated. Only SELECT, own display_name update, conversation input columns and title/status/deleted_at updates granted. All user DELETE/TRUNCATE attempts denied. |
| SECURITY DEFINER | Only private.has_active_membership; fully qualified tables/auth.uid, empty search_path, no SQL input, no user override, no public/anon execute. Helper schema is not API-exposed. |
| Automatic API exposure | Local Data API schema list is only empty api. Public/private remain excluded. Independent table permissions and policies are tested; HTTP API validation needs Docker and remains a separate gate. |
| History | Append-only messages; immutable run inputs/terminal rows; one-way void; insight resolution only; RESTRICT relationships. Administrative purge is not a product capability. |
| Scripts | Supabase tests target a fixed local container; standalone creates its own temporary cluster, uses no network listener and accepts no remote URL. Fixture data rolls back. |
| Snapshots | Object/version consistency checked; no JSON relationships or authorization. Semantic schema, evidence provenance and sanitization remain future application responsibilities. |
| Source/bundle | No application source changes or secret values introduced. New CLI is development-only. Final browser bundle scan recorded in log 0005. |

Residual validation boundary: native PostgreSQL validates real grants/RLS/constraints but supplies a minimal auth.users fixture boundary. Run the documented Supabase reset/lint/tests on Docker before treating full-stack local validation as complete. Future application authorization and server-only AI writes require their own integration tests; this increment does not claim those capabilities.

Final validation: PostgreSQL 17.9 ran both SQL suites on each of two clean databases, reporting 198 successful checks per database (396 total) and identical schema dumps. All M01–M13 migrations were preserved. Manual contract comparison confirmed the exact nine secondary index definitions, composite tenant-safe FKs, TEXT/CHECK domains, TIMESTAMPTZ, historical guards and active/nondeleted account membership helper. No policy uses ALL or DELETE. Full Supabase validation remains BLOCKED, not a project test failure.
