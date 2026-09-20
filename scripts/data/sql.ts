import { type Dataset } from "./generator";
import { COLUMNS, validate } from "./validation";

function literal(value: unknown): string {
  if (value === null) return "NULL";
  if (typeof value !== "string") throw new Error("Unsupported SQL value");
  return "'" + value.replaceAll("'", "''") + "'";
}
export function toSql(dataset: Dataset): string {
  validate(dataset);
  const statements = ["-- Administrative LOCAL demo/test fixture, never a schema migration.",
    "BEGIN;", "SET LOCAL standard_conforming_strings = on;",
    "SELECT pg_advisory_xact_lock(20260919);",
  ];
  const tables = [
    ["gym_units", [dataset.gymUnit]], ["members", dataset.members], ["access_records", dataset.accesses],
  ] as const;
  for (const [table, rows] of tables) {
    const columns = COLUMNS[table];
    statements.push(`CREATE TEMP TABLE seed_${table} (LIKE public.${table} INCLUDING DEFAULTS) ON COMMIT DROP;`);
    for (let offset = 0; offset < rows.length; offset += 500) {
      const values = rows.slice(offset, offset + 500).map((row) => {
        const record = row as unknown as Record<string, unknown>;
        return `(${columns.map((column) => literal(record[column])).join(",")})`;
      });
      statements.push(`INSERT INTO seed_${table} (${columns.join(",")}) VALUES\n${values.join(",\n")};`);
    }
    // Idempotency never updates facts or invokes updated_at triggers. Reject drift atomically.
    statements.push(`DO $$ BEGIN
IF EXISTS (SELECT 1 FROM public.${table} t JOIN seed_${table} s USING (id) WHERE to_jsonb(t) IS DISTINCT FROM to_jsonb(s)) THEN
  RAISE EXCEPTION 'Existing ${table} differs from deterministic seed; use a fresh local database';
END IF;
END $$;`);
    statements.push(`INSERT INTO public.${table} (${columns.join(",")}) SELECT ${columns.map((c) => `s.${c}`).join(",")} FROM seed_${table} s WHERE NOT EXISTS (SELECT 1 FROM public.${table} t WHERE t.id = s.id);`);
    if (table !== "gym_units") statements.push(`DO $$ BEGIN
IF EXISTS (SELECT 1 FROM public.${table} t WHERE t.gym_unit_id = ${literal(dataset.gymUnit.id)} AND NOT EXISTS (SELECT 1 FROM seed_${table} s WHERE s.id = t.id)) THEN
  RAISE EXCEPTION 'Unexpected existing rows in demo tenant';
END IF;
END $$;`);
  }
  statements.push("COMMIT;");
  return statements.join("\n") + "\n";
}
