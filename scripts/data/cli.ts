import { mkdirSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { generate } from "./generator";
import { toSql } from "./sql";
import { validate } from "./validation";

const output = resolve("node_modules/.cache/synthetic-dataset");
const dataset = generate();
validate(dataset);
mkdirSync(output, { recursive: true });
writeFileSync(resolve(output, "dataset.sql"), toSql(dataset));
writeFileSync(resolve(output, "operational.json"), JSON.stringify({ gym_units: [dataset.gymUnit], members: dataset.members, access_records: dataset.accesses }, null, 2) + "\n");
writeFileSync(resolve(output, "test-metadata.json"), JSON.stringify({ config: dataset.config, scenario: dataset.scenario, profiles: dataset.profiles, morningControl: dataset.morningControl }, null, 2) + "\n");
console.log(JSON.stringify({ output, seed: dataset.config.seed, asOfDate: dataset.config.asOfDate, members: dataset.members.length, access_records: dataset.accesses.length }));
