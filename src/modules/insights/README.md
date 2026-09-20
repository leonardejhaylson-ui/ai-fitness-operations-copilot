# Insight Engine

`evaluateInsights(input)` is the deterministic Rule Set v0.1 evaluator.

It consumes already-authorized Metrics Engine outputs for the same unit and analytical reference: 7-day metrics drive unit attendance and hourly flow rules; 30-day metrics drive member frequency decline and prolonged absence. Current member status is supplied separately because the absence rule explicitly requires `member.status = ACTIVE`.

Rule thresholds and severity mapping come from the approved Data Model & Synthetic Dataset Specification v0.1 and UI Screen Specification v0.1. The internal legacy type `UNUSUALLY_LOW_OCCUPANCY` is retained for database compatibility, but its evidence and future UI must describe **access flow**, never simultaneous occupancy.

Rule Set `MVP_RULES_V1`:

- ATTENDANCE_DROP: WARNING at <= -10%; HIGH at <= -20%.
- MEMBER_FREQUENCY_DROP: <= -40%, previous accesses >= 4 and absolute drop >= 2; HIGH at <= -60%.
- PROLONGED_ABSENCE: ACTIVE member, >= 10 days since last valid visit and historical frequency >= 1/week; HIGH at >= 21 days.
- UNUSUALLY_LOW_OCCUPANCY: hourly access-flow change <= -25%, previous share >= 5%, previous count >= 20; HIGH at <= -40%.

Exact threshold values belong to typed, versioned code, not a user-configurable table. Every candidate carries its rule code/version, comparison periods and a versioned evidence snapshot.

The engine does not persist `operational_insights`, resolve historical snapshots, authorize users, query PostgreSQL, render UI copy or call AI. Current facts remain reproducible from raw data + Metrics Engine + rule version. A future persistence adapter may snapshot candidates after application authorization.
