# Metrics Engine

`calculateMetrics(input)` is the pure public entry point. Supply a server-authorized GymUnit, its members and complete authorized access history, an offset-bearing ISO reference instant, and `duration_days: 7 | 30`. No authentication, database access, persistence, UI formatting or insight classification occurs here. Cross-unit rows, unknown members and duplicate IDs are rejected; these checks do not establish user authorization or replace RLS.

Periods are adjacent `[start,end)` intervals of exactly 7 or 30 elapsed 24-hour days. The reference instant is exclusive for interval counts. Callers resolve their desired reference instant; the Golden reference is `2026-09-19T03:00:00Z`, local midnight on September 19. Equal elapsed durations remain equivalent across DST, though a boundary may fall away from local midnight. Daily bins include every local calendar date touched by the interval, including partial dates and zero counts. Weekday indices are Sunday=0 through Saturday=6; hourly indices are 0 through 23. Repeated DST hours share a bin. Native `Intl.DateTimeFormat` uses the unit's IANA zone, never a fixed offset or the host timezone.

Definitions follow Data Model Specification §§23–32 and Database Contract §§11–12:

- Active members: `joined_at < end`, `deactivated_at === null || deactivated_at >= end`, and `deleted_at === null`. Current status does not rewrite historical activity.
- Total accesses: every VALID unit access inside the interval, independent of current member status. VOIDED facts never contribute.
- Average visits: total accesses / active members, without weekly normalization. A zero denominator returns null.
- Attendance and member frequency change: `(current - previous) / previous * 100`; zero baseline, including 0 → 0, returns null (not comparable).
- Member output includes every supplied member, including members with no history, inactive and deleted members. Future consumers can select their relevant population. It includes raw visits and weekly frequency `visits * 7 / duration_days`; equal durations make frequency percentage change identical to visit percentage change.
- Last visit follows §32's separate snapshot definition `occurred_at <= reference instant`, including history before either comparison interval. Thus a visit exactly at the reference does not enter interval counts but is the last visit at that instant. Days since last visit is the difference between local calendar dates, not elapsed 24-hour blocks. No history returns null for both fields.

Results retain full numeric precision and include both periods, timezone, unit and calculation version. There is no global clock, threshold, simultaneous occupancy inference or generated classification. Return order is stable by member ID and local date.

The caller is responsible for complete history: truncated input cannot prove a member has never visited. This in-memory MVP implementation does not add a speculative repository; a future authorized database adapter can supply facts or implement the approved hybrid aggregation strategy. Timezone rules follow the runtime's ICU/tzdata version.

Tests: `pnpm exec vitest run src/modules/metrics`. Golden integration generates the approved fixture in memory without PostgreSQL/Supabase or importing generator logic into production code.
