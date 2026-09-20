# AI Log 0012: Auth and Release Hardening

- Date: 2026-09-20
- Branch: `codex/auth-release`

## Scope

Supabase Auth SSR integration, protected analytical routes, login/logout entry points, API authentication check preparation, dependency/security patching and release-oriented validation.

## Dependencies

User-generated pnpm lockfile update added:
- `@supabase/ssr`
- `@supabase/supabase-js`
- Next.js patched from 15.5.2 to 15.5.7
- `eslint-config-next` aligned to 15.5.7

## Auth design

Uses server-side Supabase Auth with cookies. The login action calls `signInWithPassword`; middleware refreshes/authenticates sessions and protects the operational page routes. Logout is a server action.

If Supabase env vars are absent, protected routes fail closed by redirecting to `/login`; the login page remains renderable so local build/E2E do not require secrets.

No fake credentials, hardcoded demo password, service-role key or browser-side privileged token were introduced.

## Important limitation

The current application data remains the explicit synthetic demo adapter. Authentication is real when configured, but database-backed User -> UserGymUnit authorization is not claimed by this increment because the current Data API intentionally does not expose public domain tables. Real tenant data must not be connected until the reviewed application authorization boundary is implemented.

## Validation

Pending:
- pnpm lint
- pnpm typecheck
- pnpm test
- pnpm build
- pnpm test:e2e
- git diff --check
