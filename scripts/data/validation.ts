import { bounds, type Dataset } from "./generator";

export const COLUMNS = {
  gym_units: ["id", "name", "code", "timezone", "status", "created_at", "updated_at", "deleted_at"],
  members: ["id", "gym_unit_id", "member_code", "display_name", "status", "joined_at", "deactivated_at", "created_at", "updated_at", "deleted_at"],
  access_records: ["id", "gym_unit_id", "member_id", "occurred_at", "status", "created_at", "voided_at"],
} as const;
export function validate(dataset: Dataset) {
  const fail = (message: string): never => { throw new Error(message); };
  const { start, end } = bounds(dataset.config);
  const exact = (row: object, columns: readonly string[]) => {
    if (Object.keys(row).sort().join() !== [...columns].sort().join()) fail("Unexpected operational columns");
  };
  exact(dataset.gymUnit, COLUMNS.gym_units);
  if (dataset.gymUnit.id !== dataset.config.gymUnitId || dataset.gymUnit.timezone !== dataset.config.timezone) fail("Unit mismatch");
  if (dataset.members.length !== 500) fail("Expected 500 members");
  if (dataset.accesses.length < 25000 || dataset.accesses.length > 35000) fail("Access volume outside 25k–35k");
  const members = new Map(dataset.members.map((m) => [m.id, m]));
  if (members.size !== dataset.members.length) fail("Duplicate member ID");
  if (new Set(dataset.members.map((m) => m.member_code)).size !== members.size) fail("Duplicate member code");
  const ids = new Set<string>();
  const instant = (value: string) => {
    if (!/^\d{4}-\d{2}-\d{2}T.*Z$/.test(value) || !Number.isFinite(Date.parse(value))) fail("Invalid timestamp");
    return Date.parse(value);
  };
  for (const member of dataset.members) {
    exact(member, COLUMNS.members);
    if (member.gym_unit_id !== dataset.gymUnit.id) fail("Cross-tenant member");
    if (member.status !== "ACTIVE" || member.deactivated_at !== null || member.deleted_at !== null) fail("Invalid demo member lifecycle");
    if (instant(member.joined_at) > start || instant(member.updated_at) < instant(member.created_at)) fail("Invalid member history");
  }
  for (const access of dataset.accesses) {
    exact(access, COLUMNS.access_records);
    if (ids.has(access.id)) fail("Duplicate access ID");
    ids.add(access.id);
    const member = members.get(access.member_id);
    if (!member || access.gym_unit_id !== member.gym_unit_id) throw new Error("Cross-tenant or missing member access");
    const time = instant(access.occurred_at);
    if (time < start || time >= end || time < instant(member.joined_at)) fail("Access outside history window");
    if (instant(access.created_at) < time || instant(access.created_at) >= end) fail("Invalid creation timestamp");
    if (access.status === "VALID" ? access.voided_at !== null : access.status !== "VOIDED" || access.voided_at === null)
      fail("Invalid VOIDED state");
    if (access.voided_at !== null && (instant(access.voided_at) < instant(access.created_at) || instant(access.voided_at) >= end)) fail("Invalid void timestamp");
  }
}
