# Mandatory Security Rules

1. Derive authenticated identity and active tenant from trusted server-side state; never authorize from a tenant ID supplied by the browser.
2. Scope every tenant-owned read/write and validate membership/role at the application boundary.
3. Apply RLS to tenant-owned data as defense in depth. Application checks and RLS are both required; neither substitutes for the other.
4. Never expose service-role keys, LLM API keys, privileged tokens, or secrets in client code or `NEXT_PUBLIC_` variables.
5. Never give an LLM database credentials, unrestricted row data, or the ability to compose/execute free-form SQL.
6. Minimize the AI context to authorized evidence and validate output against supplied evidence before presenting it as grounded.
7. Treat boundary input and model output as untrusted. Validate shape, size, and allowed values.
8. Do not log secrets, access tokens, sensitive prompts, or unnecessary personal/tenant data.
9. Add negative authorization and cross-tenant isolation tests with every relevant capability.
10. Changes to the Database Contract or Security Threat Model require explicit human review and a recorded decision.

The approved Security Threat Model and Database Contract remain authoritative. Their content must be imported before security- or data-bearing feature work begins.
