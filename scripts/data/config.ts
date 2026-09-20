export const CONFIG = {
  datasetVersion: "fitness-demo-v1",
  seed: 20260919,
  asOfDate: "2026-09-19",
  gymUnitId: "f17e5500-0000-5000-8000-000000000001",
  timezone: "America/Sao_Paulo",
  historyDays: 180,
} as const;

export const PROFILES = {
  frequent: 75, regular: 175, low: 75, irregular: 75,
  declining: 40, apparent_abandonment: 25, prolonged_absence: 35,
} as const;
export type Profile = keyof typeof PROFILES;
export type Scenario = "baseline" | "attendance" | "weekday" | "evening" | "member" | "absence" | "demo";
export const SCENARIOS: Scenario[] = ["baseline", "attendance", "weekday", "evening", "member", "absence", "demo"];
export type Config = Omit<typeof CONFIG, "seed" | "asOfDate" | "gymUnitId"> & {
  seed: number; asOfDate: string; gymUnitId: string;
};
