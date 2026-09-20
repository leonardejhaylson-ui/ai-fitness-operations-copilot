# Local database foundation

The [Database Contract v0.1](normative/06-database-contract-v0.1.md) is authoritative. This increment contains exactly `app_users`, `gym_units`, `user_gym_units`, `members`, `access_records`, `operational_insights`, `ai_conversations`, `ai_messages`, and `ai_runs`.

## Supabase local workflow

Prerequisites: Node/pnpm from README and a running Docker-compatible environment. The development-only `supabase` CLI is pinned in package.json/lockfile, following the [official installation instructions](https://supabase.com/docs/guides/local-development/cli/getting-started). No global install, remote project, `supabase link`, login, production configuration or ORM is required.

```sh
pnpm install --frozen-lockfile
pnpm db:start
pnpm db:reset
pnpm db:lint
pnpm test:db
# Reproducibility: rebuild the local database and rerun.
pnpm db:reset
pnpm test:db
pnpm db:stop
```

`db:reset` deletes/rebuilds only the local development database. Seed is disabled. Tests use tiny rollback-only fixtures, not a synthetic dataset. `test:db` targets the fixed local project container and needs Docker CLI; it does not accept a remote connection string. Run from a trusted local machine; container network exposure depends on the Docker host configuration. No application credentials are needed by the current Next.js shell.

## Native PostgreSQL validation when Docker is unavailable

Put PostgreSQL **17** binaries (`initdb`, `pg_ctl`, `createdb`, `psql`, `pg_dump`) on PATH:

```sh
pnpm test:db:standalone
```

The harness creates a private disposable cluster under ignored `node_modules/.cache`, listens only on a private Unix socket, ignores inherited connection variables and cleans up on exit. It applies every migration to two separate empty databases, runs the same SQL integration suite in both, and compares schema dumps. Existing databases are never reset. No package or global installation happens inside this command.

Standalone bootstrap defines a minimal `auth.users(id)` fixture boundary, platform roles and [Supabase's auth.uid semantics](https://github.com/supabase/auth/blob/master/migrations/20220224000811_update_auth_functions.up.sql). Database tests set request claims and switch to the actual non-BYPASSRLS `authenticated`/`anon` PostgreSQL roles. All constraints, triggers, grants and policies run in the real engine. This validates database authorization, **not** token verification, full Auth schema compatibility, HTTP APIs or the full Supabase stack. Those require the workflow above.

## Migration order

| Step | Content |
| --- | --- |
| M01 | Private helpers, automatic updated_at, empty API schema, restrictive defaults |
| M02–M05 | app_users, gym_units, user_gym_units, members |
| M06 | access_records and one-way void guard |
| M07 | operational_insights and immutable snapshot/resolution guard |
| M08–M09 | ai_conversations and append-only ai_messages |
| M10 | ai_runs, terminal consistency, immutable inputs/terminal rows |
| M11 | Complete tenant-safe message → run foreign key |
| M12 | Exactly the nine approved secondary indexes |
| M13 | Explicit grants, RLS and membership/ownership policies |
| M14 | Tests in supabase/tests/database; never production fixtures/migrations |

Built-in `gen_random_uuid()` needs no extension on PostgreSQL 17. All operational timestamps use TIMESTAMPTZ; unit timezone remains an explicit IANA-name field. Application IANA validation and future period aggregation are not implemented here.

## Access and history

The local Data API exposes only empty `api`, not domain tables or private helpers. Independent grants and RLS deny anonymous access and enforce current membership for authenticated tenant reads. Profiles are self-only; AI conversations/messages/runs also require owner identity. Inactive membership immediately removes access even with unchanged claims. Inactive/deleted application accounts cannot access tenant data.

Only `display_name` is user-updatable in app_users. Conversation inserts allow `gym_unit_id`, `user_id`, `title` under RLS; updates allow `title`, `status`, `deleted_at`. Tenant/owner/creation fields cannot be reassigned by users. Browser IDs are never authorization; the eventual application must derive identity, resolve tenant and authorize before querying.

No end-user writes to members, accesses, insights, messages or runs; no end-user DELETE or TRUNCATE anywhere. Controlled provisioning/fixtures remain administrative. Future Copilot/Insight server writes require their own reviewed RLS-preserving boundary; there is no service-role-backed request path. The only SECURITY DEFINER function returns membership for the current identity, uses fully qualified relations and empty search_path, and is not exposed by the API.

History guards allow only VALID → VOIDED access correction, filling insight resolved_at, and STARTED → terminal run completion. Message updates and terminal-run updates are rejected. Run input snapshots/versions cannot change during completion. FKs use RESTRICT and preserve tenant, conversation and owner alignment. Privileged exceptional deletion is not a product operation; no retention/purge job is introduced.

JSON object/version checks are database-local. Semantic snapshot contents, request USER/response ASSISTANT roles, exact audited question, validated-output provenance, evidence IDs and error sanitization remain application/test responsibilities from Contract §6.2/§10. Failure snapshots may be present only when usable validated output exists, as specified; that provenance cannot be inferred by a SQL CHECK.
