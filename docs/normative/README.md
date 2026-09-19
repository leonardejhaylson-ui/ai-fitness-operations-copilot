# Normative Project Artifacts

This directory is the controlled location for the seven approved v0.1 artifacts. The bootstrap request supplied their titles but **not their contents**. To avoid inventing requirements, each named file currently contains an import notice rather than a reconstruction.

Before any feature, data, security, or product UI implementation:

1. obtain the approved source documents;
2. replace each notice with a faithful Markdown transcription (or add the approved original file and update this index);
3. preserve version, authorship/approval metadata, tables, diagrams, and normative language;
4. have a human reviewer verify fidelity; and
5. record the import in `ai/logs/` and, if it changes an implementation decision, an ADR.

## Documents and precedence

1. [Security Threat Model v0.1](07-security-threat-model-v0.1.md) and [Database Contract v0.1](06-database-contract-v0.1.md) govern their security/data invariants.
2. [Architecture v0.1](02-architecture-v0.1.md) and [Product Specification v0.1](01-product-specification-v0.1.md).
3. [Data Model & Synthetic Dataset Specification v0.1](03-data-model-and-synthetic-dataset-specification-v0.1.md).
4. [Product UX, Design Direction & Design System v0.1](04-product-ux-design-direction-and-design-system-v0.1.md).
5. [UI Screen Specification v0.1](05-ui-screen-specification-v0.1.md).

This operational precedence is recorded for conflicts; it does not alter any artifact. Escalate genuine conflicts for review.
