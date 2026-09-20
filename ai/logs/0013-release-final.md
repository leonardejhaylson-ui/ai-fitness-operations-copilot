# AI Log 0013: Release Finalization

- Date: 2026-09-20
- Branch: `codex/release-final`

## Scope

Final release hardening for the synthetic-data demonstration:
- browser security headers;
- removal of unused service-role configuration from the example environment;
- best-effort Copilot request throttling;
- release documentation refresh.

## Security headers

Next.js applies:
- Content-Security-Policy;
- X-Content-Type-Options: nosniff;
- Referrer-Policy: strict-origin-when-cross-origin;
- Permissions-Policy disabling camera, microphone and geolocation;
- X-Frame-Options: DENY.

The CSP permits the minimal script/style behavior required by the current Next.js application and blocks framing/object embedding.

## Copilot request limit

The Copilot API uses an authenticated-user + forwarded-address key with an in-process 10 requests/minute limiter before the OpenAI provider call.

This is intentionally documented as **best effort only**. Serverless instances do not share memory, therefore this mechanism is not a durable distributed production quota. It reduces accidental/demo burst traffic without adding infrastructure immediately before delivery. A shared store/platform rate limiter remains the correct future production implementation.

## Secrets

`SUPABASE_SERVICE_ROLE_KEY` was removed from `.env.example` because the current application does not use it. The normal request path remains anon-key + authenticated session + future RLS-preserving authorization.

## Release boundary

The deployed MVP is a synthetic-data demonstration. Authentication can be real when Supabase variables are configured. Operational data still comes from the deterministic synthetic adapter and must not be described as a production tenant database integration.

## Validation

Pending local:
- pnpm lint
- pnpm typecheck
- pnpm test
- pnpm build
- pnpm test:e2e
- git diff --check
