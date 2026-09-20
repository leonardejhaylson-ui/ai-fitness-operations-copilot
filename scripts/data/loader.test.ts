// @vitest-environment node
import { spawnSync } from "node:child_process";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { expect, it } from "vitest";

it("requires an explicit local target before running any command", () => {
  for (const args of [[], ["--remote"], ["--local", "extra"]]) {
    const result = spawnSync("sh", ["scripts/data/load-local.sh", ...args], { encoding: "utf8" });
    expect(result.status).toBe(1);
    expect(result.stderr).toContain("Usage:");
    expect(result.stdout).toBe("");
  }
});

it("pins the local Docker socket/container even with inherited remote settings", () => {
  const directory = mkdtempSync(join(tmpdir(), "fitness-loader-test-"));
  const log = join(directory, "calls");
  try {
    // No actual generation or database process: record only the loader's argv.
    for (const command of ["pnpm", "docker"]) writeFileSync(join(directory, command), '#!/bin/sh\nprintf "%s\\n" "$0" "$@" >> "$LOADER_TEST_LOG"\n', { mode: 0o700 });
    mkdirSync(join(directory, "scripts/data"), { recursive: true });
    mkdirSync(join(directory, "node_modules/.cache/synthetic-dataset"), { recursive: true });
    writeFileSync(join(directory, "scripts/data/load-local.sh"), readFileSync("scripts/data/load-local.sh"));
    writeFileSync(join(directory, "node_modules/.cache/synthetic-dataset/dataset.sql"), "-- empty test fixture\n");
    const result = spawnSync("sh", [join(directory, "scripts/data/load-local.sh"), "--local"], {
      env: { NODE_ENV: "test", PATH: `${directory}:/usr/bin:/bin`, LOADER_TEST_LOG: log, DOCKER_HOST: "tcp://invalid.example:2375", DOCKER_CONTEXT: "remote" }, encoding: "utf8",
    });
    expect(result.status).toBe(0);
    const calls = readFileSync(log, "utf8");
    expect(calls).toContain("--host\nunix:///var/run/docker.sock\nexec\n-i\nsupabase_db_ai-fitness-operations-copilot\npsql\n-X\n-U\npostgres\n-d\npostgres\n-v\nON_ERROR_STOP=1");
  } finally { rmSync(directory, { recursive: true, force: true }); }
});
