# Architecture Conventions

## Shape

Use a modular monolith. Next.js App Router is the delivery mechanism, not the home of business rules. Route handlers, Server Actions, and pages validate/translate delivery concerns and delegate to application use cases.

Create module folders only when a feature is approved and implemented. Within a module, dependencies point inward: delivery -> application -> domain. Infrastructure implements ports owned by inner layers. Cross-module calls use explicit public contracts rather than importing internal files.

## Determinism and AI boundary

- PostgreSQL is the system of record.
- Metrics Engine computes reproducible facts from defined inputs.
- Insight Engine applies reproducible rules to those facts.
- AI Context Builder selects only authorized, necessary, calculated evidence.
- LLM Gateway isolates model-provider concerns.
- Evidence Validator rejects unsupported or malformed interpretation before delivery.
- LLM output is interpretation, never the source of metric values, permissions, or database queries. Free-form SQL from an LLM is prohibited.

## Delivery and data

Perform authorization server-side before invoking application behavior. Repositories/data adapters must accept explicit tenant context and use parameterized, contract-compliant access. RLS remains enabled as defense in depth. Do not couple domain logic to React, Next.js request objects, Supabase clients, or model-provider SDKs.

## UI

Implement only screens and components justified by the approved UX/design and UI Screen specifications. Prefer Server Components by default; add Client Components only for genuine browser interactivity.
