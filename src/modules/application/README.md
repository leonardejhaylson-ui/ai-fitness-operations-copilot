# Application orchestration

`loadDemoOperations()` is the explicit synthetic-data adapter used while the real authorized PostgreSQL/Supabase application adapter is not yet connected.

It composes the approved deterministic pipeline:

`synthetic facts -> Metrics Engine -> Insight Engine -> application view`

The adapter is deliberately not presented as authentication or authorization. It accepts no browser-provided tenant ID, performs no writes, exposes no secrets and contains only the approved synthetic fixture. Real tenant data must later enter through a server-side authorized repository/application boundary with RLS defense in depth.

This layer exists so the UI can consume one stable application-facing model instead of importing generator, metrics and insight internals independently.
