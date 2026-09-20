# AI Log 0010: Operational Demo UI

- Date: 2026-09-20
- Branch: `codex/demo-ui`
- Scope: presentation-only operational demo surfaces over the merged deterministic application snapshot.

## Objective

Turn the validated deterministic pipeline into a presentation-ready, data-oriented interface without waiting for the unavailable Codex quota. The UI consumes `loadDemoOperations()`; it does not recalculate business rules.

## Implemented surfaces

- `/overview`: metric strip, daily access trend, priority situations and hourly-flow summary.
- `/attendance`: access metrics, daily comparison, hourly distribution and related deterministic situations.
- `/members`: first 25 members in semantic desktop table with approved columns and investigation links.
- `/members/:memberId`: individual frequency facts and member situations.
- `/insights`: full deterministic situation list.
- `/copilot`: approved contextual shell and suggestions; provider input remains intentionally disabled until AI integration.
- `/`: redirects to `/overview` for the synthetic demo.

## UX decisions

Uses the approved design tokens and direction: Canvas/Surface/Ink/Action palette, restrained semantic WARNING/HIGH colors, borders instead of analytical shadows, radius <= 8px, medium-density operational layout, 232px desktop sidebar, metric strip rather than KPI cards, PT-BR labels, and access-flow language rather than simultaneous occupancy.

No chart dependency was added. Small deterministic bar visualizations are rendered with semantic HTML/CSS and exact values remain visible. This avoids introducing a chart package immediately before delivery.

The members page intentionally renders 25 rows. Search/filter controls are visually present but disabled in this increment rather than pretending client functionality exists. Pagination next is also presentation-only pending interactive state.

## Security and architecture

No authentication bypass route or fake credential flow was added. No service-role usage, browser secret, database access, OpenAI call, tenant selector or write path exists. The UI uses only the deterministic synthetic demo adapter.

The Copilot page explicitly does not fake an LLM response. The prompt and suggestions are presentation shell only until the real server-side context/gateway/evidence path is implemented.

## Validation status

Pending local execution:

- `pnpm lint`
- `pnpm typecheck`
- `pnpm test`
- `pnpm build`
- `pnpm test:e2e` (now applicable because critical routes changed)
- `git diff --check`

No package, lockfile, migration or normative document change.
