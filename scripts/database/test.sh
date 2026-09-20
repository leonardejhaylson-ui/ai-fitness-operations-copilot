#!/bin/sh
# Runs only against this project's local Supabase container. No remote URL accepted.
set -eu
cd "$(dirname "$0")/../.."
command -v docker >/dev/null 2>&1 || { echo 'BLOCKED: Docker is required; alternatively use pnpm test:db:standalone with PostgreSQL 17 binaries.' >&2; exit 1; }
for test_file in supabase/tests/database/*.sql; do
  docker exec -i supabase_db_ai-fitness-operations-copilot psql -X -U postgres -d postgres -v ON_ERROR_STOP=1 < "$test_file"
done
