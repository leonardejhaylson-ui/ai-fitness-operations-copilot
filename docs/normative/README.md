# Normative Project Artifacts

This directory contains the seven approved v0.1 normative artifacts for the AI Fitness Operations Copilot.

They are controlled project sources of truth. Implementation agents must preserve their normative meaning and must not silently reconcile or override genuine conflicts.

## Documents and precedence

1. [Security Threat Model v0.1](07-security-threat-model-v0.1.md) and [Database Contract v0.1](06-database-contract-v0.1.md) govern their security/data invariants.
2. [Architecture v0.1](02-architecture-v0.1.md) and [Product Specification v0.1](01-product-specification-v0.1.md).
3. [Data Model & Synthetic Dataset Specification v0.1](03-data-model-and-synthetic-dataset-specification-v0.1.md).
4. [Product UX, Design Direction & Design System v0.1](04-product-ux-design-direction-and-design-system-v0.1.md).
5. [UI Screen Specification v0.1](05-ui-screen-specification-v0.1.md).

This operational precedence exists only to guide conflict handling; it does not rewrite any artifact. Genuine conflicts must be escalated for review.

## Change control

- Do not edit normative artifacts as part of ordinary implementation work.
- Any proposed normative change must be explicitly reviewed and recorded.
- ADRs may clarify implementation choices but cannot silently override these documents.
- Material imports or normative revisions must be recorded in `ai/logs/`.
