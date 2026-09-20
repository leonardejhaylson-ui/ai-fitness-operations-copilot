// @vitest-environment node
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { CONFIG, PROFILES, type Scenario } from "./config";
import { bounds, generate, localParts, type Access } from "./generator";
import { validate, COLUMNS } from "./validation";
import { toSql } from "./sql";

const demo = generate();
const baseline = generate("baseline");
const end = bounds(CONFIG).end;
const window = (rows: Access[], days: number, offset = 0) => rows.filter((a) => a.status === "VALID" && Date.parse(a.occurred_at) >= end - (days + offset) * 86400000 && Date.parse(a.occurred_at) < end - offset * 86400000);
const ratio = (rows: Access[], filter: (a: Access) => boolean = () => true) => window(rows, 7).filter(filter).length / window(rows, 7, 7).filter(filter).length;
const hour = (a: Access) => localParts(a.occurred_at).hour;
const fingerprint = (data: typeof demo) => createHash("sha256").update(JSON.stringify(data)).digest("hex");

describe("deterministic synthetic dataset", () => {
  it("pins the full Golden fingerprint, IDs, configuration and raw 7/30-day counts", () => {
    const golden = JSON.parse(readFileSync(new URL("./golden.json", import.meta.url), "utf8"));
    expect({ config: demo.config, members: demo.members.length, accesses: demo.accesses.length,
      valid: demo.accesses.filter(a => a.status === "VALID").length,
      voided: demo.accesses.filter(a => a.status === "VOIDED").length,
      current7: window(demo.accesses, 7).length, previous7: window(demo.accesses, 7, 7).length,
      current30: window(demo.accesses, 30).length, previous30: window(demo.accesses, 30, 30).length,
      sha256: fingerprint(demo) }).toEqual(golden.observed);
    const repeated = generate();
    expect(fingerprint(repeated)).toBe(golden.observed.sha256);
    expect(repeated.members.map(m => m.id)).toEqual(demo.members.map(m => m.id));
    expect(demo.members.filter(m => demo.profiles[m.id] === "declining").map(m => m.id)).toEqual(golden.expected.memberSignals.declining);
    expect(demo.members.filter(m => demo.profiles[m.id] === "prolonged_absence").map(m => m.id)).toEqual(golden.expected.memberSignals.absent);
  });
  it("has exact approved profile volumes without operational labels", () => {
    expect(demo.members).toHaveLength(500);
    for (const [profile, count] of Object.entries(PROFILES)) expect(Object.values(demo.profiles).filter(p => p === profile)).toHaveLength(count);
    expect(new Set(demo.members.map(row => Object.keys(row).sort().join()))).toEqual(new Set([[...COLUMNS.members].sort().join()]));
    expect(new Set(demo.accesses.map(row => Object.keys(row).sort().join()))).toEqual(new Set([[...COLUMNS.access_records].sort().join()]));
    const sql = toSql(demo);
    expect(sql).not.toMatch(/synthetic_profile|declining|prolonged_absence|morningControl|profiles/);
    expect(sql).not.toMatch(/UPDATE public|DELETE FROM|TRUNCATE|DISABLE|row_security/);
  });
  it("validates all generated history, tenant references, IDs and VOIDED timestamps", () => {
    expect(() => validate(demo)).not.toThrow();
    const formatter = new Intl.DateTimeFormat("en-CA", { timeZone: CONFIG.timezone, hourCycle: "h23", hour: "2-digit" });
    for (const a of demo.accesses.filter((_, i) => i % 100 === 0)) expect(Number(formatter.format(new Date(a.occurred_at)))).toBe(hour(a));
    expect(demo.accesses.some(a => a.occurred_at.slice(11, 13) === "01")).toBe(true); // 22h local, next UTC day
  });
  it.each([
    ["wrong member tenant", (d: typeof demo) => { d.members[0].gym_unit_id = "other"; }],
    ["cross-tenant access", (d: typeof demo) => { d.accesses[0].gym_unit_id = "other"; }],
    ["missing member", (d: typeof demo) => { d.accesses[0].member_id = "missing"; }],
    ["duplicate ID", (d: typeof demo) => { d.accesses[0].id = d.accesses[1].id; }],
    ["outside window", (d: typeof demo) => { d.accesses[0].occurred_at = new Date(end).toISOString(); }],
    ["invalid void", (d: typeof demo) => { d.accesses[0].status = "VOIDED"; d.accesses[0].voided_at = null; }],
    ["early void", (d: typeof demo) => { d.accesses[0].status = "VOIDED"; d.accesses[0].voided_at = "2000-01-01T00:00:00Z"; }],
    ["label leakage", (d: typeof demo) => { Object.assign(d.members[0], { synthetic_profile: "declining" }); }],
  ])("rejects %s before SQL emission", (_, mutate) => {
    const data = structuredClone(demo); mutate(data);
    expect(() => validate(data)).toThrow(); expect(() => toSql(data)).toThrow();
  });
  it("changes explicit seeds/tenant IDs and rejects unsupported input", () => {
    expect(generate("baseline", { ...CONFIG, seed: 42 }).accesses[0].id).not.toBe(baseline.accesses[0].id);
    const other = generate("baseline", { ...CONFIG, gymUnitId: "f17e5500-0000-8000-8000-000000000002" });
    expect(new Set(other.members.map(m => m.id)).has(demo.members[0].id)).toBe(false);
    for (const asOfDate of ["now", "2026-02-30", "2018-11-05"]) expect(() => generate("demo", { ...CONFIG, asOfDate })).toThrow();
  });
});

describe("Golden scenarios (raw fixture properties, no engines)", () => {
  it("A01: combined demo falls 10–15% over equivalent final weeks", () => {
    expect(ratio(demo.accesses)).toBeGreaterThanOrEqual(0.85);
    expect(ratio(demo.accesses)).toBeLessThan(0.9);
    expect(window(demo.accesses, 30).length).toBeLessThan(window(demo.accesses, 30, 30).length);
  });
  it.each([2, 3])("A02/A03: weekday %i drops detectably", weekday => {
    expect(ratio(demo.accesses, a => localParts(a.occurred_at).weekday === weekday)).toBeLessThan(0.85);
  });
  it("A04/A07: evening drops >25%, morning and dedicated controls stay stable", () => {
    expect(ratio(demo.accesses, a => hour(a) >= 18 && hour(a) < 20)).toBeLessThan(0.75);
    expect(ratio(demo.accesses, a => hour(a) >= 6 && hour(a) < 9)).toBeGreaterThan(0.9);
    expect(ratio(demo.accesses, a => hour(a) >= 6 && hour(a) < 9)).toBeLessThan(1.1);
    expect(ratio(demo.accesses, a => demo.morningControl.includes(a.member_id))).toBe(1);
  });
  it("A05: progressive members decline, with a group reduction of at least 40%", () => {
    const rows = demo.accesses.filter(a => demo.profiles[a.member_id] === "declining");
    expect(window(rows, 7).length / window(rows, 7, 28).length).toBeLessThanOrEqual(0.6);
    for (const m of demo.members.filter(m => demo.profiles[m.id] === "declining")) {
      expect(window(rows.filter(a => a.member_id === m.id), 30).length).toBeLessThan(window(rows.filter(a => a.member_id === m.id), 30, 30).length);
    }
  });
  it("A06: all prolonged absence members stay ACTIVE after >=10 days without visits", () => {
    for (const m of demo.members.filter(m => demo.profiles[m.id] === "prolonged_absence")) {
      const rows = demo.accesses.filter(a => a.member_id === m.id && a.status === "VALID");
      expect(m.status).toBe("ACTIVE");
      expect(Math.max(...rows.map(a => Date.parse(a.occurred_at)))).toBeLessThanOrEqual(end - 10 * 86400000);
      expect(window(rows, 28, 28).length).toBeGreaterThanOrEqual(8);
    }
    for (const m of demo.members.filter(m => demo.profiles[m.id] === "apparent_abandonment")) expect(window(demo.accesses.filter(a => a.member_id === m.id), 21)).toHaveLength(0);
  });
  it("A08: weekends have fewer daily accesses than weekdays", () => {
    const rows = window(baseline.accesses, 168);
    const weekend = rows.filter(a => [0, 6].includes(localParts(a.occurred_at).weekday)).length;
    expect(weekend / 48).toBeLessThan((rows.length - weekend) / 120);
  });
  it("A09: irregular controls vary weekly but retain a stable six-week total", () => {
    const rows = baseline.accesses.filter(a => baseline.profiles[a.member_id] === "irregular");
    expect(window(rows, 42).length / window(rows, 42, 42).length).toBeGreaterThan(0.9);
    expect(window(rows, 42).length / window(rows, 42, 42).length).toBeLessThan(1.1);
    const member = rows[0].member_id;
    const weeks = Array.from({ length: 6 }, (_, i) => window(rows.filter(a => a.member_id === member), 7, i * 7).length);
    expect(Math.max(...weeks) - Math.min(...weeks)).toBeGreaterThanOrEqual(3);
  });
  it("A10: baseline has only small unit-level changes", () => {
    expect(ratio(baseline.accesses)).toBeGreaterThan(0.94);
    expect(ratio(baseline.accesses)).toBeLessThan(1.06);
  });
  it.each(["attendance", "weekday", "evening", "member", "absence"] as Scenario[])("%s overlay is independently selectable and preserves baseline facts", scenario => {
    const data = generate(scenario); validate(data);
    const originals = new Map(baseline.accesses.filter(a => a.status === "VALID").map(a => [a.id, a]));
    const actual = data.accesses.filter(a => a.status === "VALID");
    expect(JSON.stringify(actual)).toBe(JSON.stringify(actual.map(a => originals.get(a.id))));
    if (scenario === "attendance") { expect(ratio(data.accesses)).toBeGreaterThan(0.85); expect(ratio(data.accesses)).toBeLessThan(0.9); }
    if (scenario === "evening") {
      expect(ratio(data.accesses, a => hour(a) >= 18 && hour(a) < 20)).toBeGreaterThan(0.7);
      expect(ratio(data.accesses, a => hour(a) >= 18 && hour(a) < 20)).toBeLessThan(0.8);
    }
    if (scenario === "weekday") {
      for (const weekday of [2, 3]) expect(ratio(data.accesses, a => localParts(a.occurred_at).weekday === weekday)).toBeLessThan(0.87);
      expect(window(data.accesses, 7).filter(a => ![2, 3].includes(localParts(a.occurred_at).weekday))).toEqual(window(baseline.accesses, 7).filter(a => ![2, 3].includes(localParts(a.occurred_at).weekday)));
    }
  });
});
