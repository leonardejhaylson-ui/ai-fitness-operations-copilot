# AI Log 0011: Copilot Core

- Date: 2026-09-20
- Branch: `codex/copilot-core`
- Scope: server-side Copilot context, OpenAI gateway, structured output, evidence validation and interactive demo UI.

## Architecture

Implements the approved path:

`authorized deterministic facts -> AI Context Builder -> OpenAI Responses API -> structured output -> Evidence Validator -> UI`

The current demo context is built only from the explicit synthetic application snapshot. The LLM receives no database connection, SQL capability, service-role credential or tenant-selection capability.

## Provider

The gateway uses native server-side `fetch` to the OpenAI Responses API so no dependency/lockfile change is needed immediately before delivery. The default model is `gpt-5.6-luna`, overridable by server-only `OPENAI_MODEL`.

Structured output uses `text.format` with a strict JSON Schema. The response contains:
- answer;
- evidence_ids;
- limitation.

The backend rejects any evidence ID that was not present in the server-built context.

## Evidence

Demo evidence IDs E1–E9 cover:
- total access change;
- active members;
- average visits per active member;
- Tuesday/Wednesday breakdown;
- 18:00–20:00 and 06:00–09:00 access flow;
- member frequency-drop situations;
- prolonged-absence situations.

The model never creates evidence facts. It can only reference these IDs.

## Safety and resilience

- question length: 1–1000 chars;
- provider timeout: 20s;
- provider/internal errors return a sanitized 503;
- raw provider payload, prompt, API key and stack are never returned to the browser;
- missing API key fails closed;
- dashboard/metrics/insights remain independent of the provider.

No unrestricted SQL, no browser OpenAI key, no service role and no AI authorization decision were added.

## UI

The Copilot screen now submits questions to `/api/copilot` and renders answer, verified evidence, period and limitation. Suggested questions remain non-causal by default.

## Validation status

Pending local execution:
- `pnpm lint`
- `pnpm typecheck`
- `pnpm test`
- `pnpm build`
- `pnpm test:e2e`
- `git diff --check`

Provider live-call validation additionally requires a valid local `OPENAI_API_KEY`. Build/tests must not require a real provider key.
