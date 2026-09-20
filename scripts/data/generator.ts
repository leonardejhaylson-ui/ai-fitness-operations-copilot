import { createHash } from "node:crypto";
import { CONFIG, PROFILES, type Config, type Profile, type Scenario, SCENARIOS } from "./config";

const DAY = 86_400_000;
export function random(seed: number) {
  let state = seed >>> 0;
  return () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let x = Math.imul(state ^ (state >>> 15), 1 | state);
    x ^= x + Math.imul(x ^ (x >>> 7), 61 | x);
    return ((x ^ (x >>> 14)) >>> 0) / 4294967296;
  };
}
export function id(key: string): string {
  const bytes = createHash("sha256").update(key).digest().subarray(0, 16);
  bytes[6] = (bytes[6] & 15) | 128;
  bytes[8] = (bytes[8] & 63) | 128;
  const h = bytes.toString("hex");
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-${h.slice(12, 16)}-${h.slice(16, 20)}-${h.slice(20)}`;
}
export interface Member {
  id: string; gym_unit_id: string; member_code: string; display_name: string;
  status: "ACTIVE"; joined_at: string; deactivated_at: null;
  created_at: string; updated_at: string; deleted_at: null;
}
export interface Access {
  id: string; gym_unit_id: string; member_id: string; occurred_at: string;
  status: "VALID" | "VOIDED"; created_at: string; voided_at: string | null;
}
export interface Dataset {
  config: Config; scenario: Scenario;
  gymUnit: { id: string; name: string; code: string; timezone: string; status: "ACTIVE";
    created_at: string; updated_at: string; deleted_at: null };
  members: Member[]; accesses: Access[];
  // Test metadata only: never serialized to operational SQL/JSON.
  profiles: Record<string, Profile>; morningControl: string[];
}
export function bounds(config: Config) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(config.asOfDate)) throw new Error("Invalid asOfDate");
  const end = Date.parse(`${config.asOfDate}T00:00:00-03:00`);
  if (!Number.isFinite(end) || new Date(end - 3 * 3600000).toISOString().slice(0, 10) !== config.asOfDate)
    throw new Error("Invalid calendar date");
  // v1 is deliberately bounded to modern Sao Paulo (no DST). Reject unsupported eras.
  if (config.asOfDate < "2020-01-01" || config.asOfDate > "2026-12-31") throw new Error("Unsupported timezone era");
  return { start: end - config.historyDays * DAY, end };
}
export function localParts(timestamp: string) {
  const local = new Date(Date.parse(timestamp) - 3 * 3600000);
  return { weekday: local.getUTCDay(), hour: local.getUTCHours() };
}

export function generate(scenario: Scenario = "demo", config: Config = CONFIG): Dataset {
  if (!SCENARIOS.includes(scenario)) throw new Error("Unknown scenario");
  if (!Number.isInteger(config.seed) || config.seed < 0 || config.seed > 0xffffffff) throw new Error("Invalid seed");
  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(config.gymUnitId)) throw new Error("Invalid unit UUID");
  const { start, end } = bounds(config);
  const created = new Date(start - 60 * DAY).toISOString();
  const prefix = `${config.datasetVersion}:${config.seed}:${config.gymUnitId}`;
  const dataset: Dataset = {
    config: { ...config }, scenario,
    gymUnit: { id: config.gymUnitId, name: "Academia Demonstração", code: "FITNESS-DEMO-V1",
      timezone: config.timezone, status: "ACTIVE", created_at: created, updated_at: created, deleted_at: null },
    members: [], accesses: [], profiles: {}, morningControl: [],
  };
  let index = 0;
  for (const [profileName, quantity] of Object.entries(PROFILES)) {
    const profile = profileName as Profile;
    for (let p = 0; p < quantity; p++, index++) {
      const memberId = id(`${prefix}:member:${index}`);
      const rng = random(config.seed + index * 7919);
      const control = index < 50;
      dataset.profiles[memberId] = profile;
      if (control) dataset.morningControl.push(memberId);
      dataset.members.push({ id: memberId, gym_unit_id: config.gymUnitId,
        member_code: `DEMO-${String(index + 1).padStart(4, "0")}`,
        display_name: `Aluno Sintético ${String(index + 1).padStart(3, "0")}`,
        status: "ACTIVE", joined_at: created, deactivated_at: null, created_at: created,
        updated_at: created, deleted_at: null });
      // Weeks anchored to the explicit reference date; one visit per selected local day.
      for (let week = 0; week < 26; week++) {
        const counts: Record<Profile, number> = {
          frequent: control ? 5 : 4 + Math.floor(rng() * 3), regular: 2 + (rng() < 0.15 ? 1 : 0),
          low: rng() < 0.25 ? 0 : 1 + (rng() < 0.4 ? 1 : 0),
          irregular: [4, 1, 5, 0, 2, 1][(week + index) % 6],
          declining: 4, apparent_abandonment: 3, prolonged_absence: 3,
        };
        const count = counts[profile];
        const days = Array.from({ length: 7 }, (_, d) => {
          const time = end - (week * 7 + d + 1) * DAY;
          const weekday = localParts(new Date(time).toISOString()).weekday;
          const weight = [0.38, 1.12, 1.05, 1.04, 1, 0.88, 0.62][weekday];
          return { time, rank: control ? (weekday === 0 || weekday === 6 ? 10 : weekday) : -Math.log(Math.max(rng(), 1e-9)) / weight };
        }).sort((a, b) => a.rank - b.rank).slice(0, count);
        for (const { time } of days) {
          const season = [1, 0.98, 1.01, 1.03, 1, 0.97][Math.min(5, Math.floor(week / 4.34))];
          const natural = 0.94 + rng() * 0.12;
          const keepNatural = rng() < Math.min(1, season * natural);
          const pick = rng();
          const hours = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 18, 19, 19, 20, 20, 21, 22];
          const hour = control ? 6 + index % 3 : profile === "frequent" ? (index % 2 ? 18 : 6) + Math.floor(pick * 3) : hours[Math.floor(pick * hours.length)];
          const occurred = time + (hour * 60 + Math.floor(rng() * 60)) * 60000 + Math.floor(rng() * 60) * 1000;
          if (time < start || (!control && !keepNatural)) continue;
          const timestamp = new Date(occurred).toISOString();
          dataset.accesses.push({ id: id(`${prefix}:access:${index}:${time}`), gym_unit_id: config.gymUnitId,
            member_id: memberId, occurred_at: timestamp, status: "VALID", created_at: timestamp, voided_at: null });
        }
      }
    }
  }
  injectAnomalies(dataset);
  // Auditable invalid duplicate fixtures from the oldest period, excluded from all Golden counts.
  for (const access of dataset.accesses.filter((a) => Date.parse(a.occurred_at) < start + 7 * DAY).slice(0, 12)) {
    dataset.accesses.push({ ...access, id: id(`${access.id}:voided`), status: "VOIDED",
      voided_at: new Date(Date.parse(access.created_at) + 60000).toISOString() });
  }
  dataset.accesses.sort((a, b) => a.occurred_at.localeCompare(b.occurred_at) || a.id.localeCompare(b.id));
  return dataset;
}

function injectAnomalies(dataset: Dataset) {
  const { scenario, config } = dataset;
  const { end } = bounds(config);
  const enabled = (name: Scenario) => scenario === "demo" || scenario === name;
  const members = new Map(dataset.members.map((m, i) => [m.id, i]));
  const control = new Set(dataset.morningControl);
  dataset.accesses = dataset.accesses.filter((a) => {
    const days = (end - Date.parse(a.occurred_at)) / DAY;
    const profile = dataset.profiles[a.member_id];
    const rank = parseInt(createHash("sha256").update(a.id).digest("hex").slice(0, 8), 16) / 4294967296;
    if (enabled("member") && profile === "declining" && days < 28 && rank > [0.4, 0.55, 0.7, 0.85][Math.floor(days / 7)]) return false;
    if (enabled("absence") && profile === "apparent_abandonment" && days < 21) return false;
    if (enabled("absence") && profile === "prolonged_absence" && days < 10 + members.get(a.member_id)! % 16) return false;
    if (days >= 7 || control.has(a.member_id)) return true;
    const { weekday, hour } = localParts(a.occurred_at);
    // Independent deterministic overlay coins; baseline records keep the same IDs.
    const coin = (tag: string) => parseInt(createHash("sha256").update(`${a.id}:${tag}`).digest("hex").slice(0, 8), 16) / 4294967296;
    if (enabled("weekday") && (weekday === 2 || weekday === 3) && coin("weekday") < 0.18) return false;
    if (enabled("evening") && hour >= 18 && hour < 20 && coin("evening") < 0.28) return false;
    if (enabled("attendance") && coin("attendance") < (scenario === "demo" ? 0.015 : 0.16)) return false;
    return true;
  });
}
