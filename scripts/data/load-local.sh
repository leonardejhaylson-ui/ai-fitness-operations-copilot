#!/bin/sh
# Administrative seed: only the fixed Supabase local development container.
set -eu
cd "$(dirname "$0")/../.."
if [ "${1-}" != '--local' ] || [ "$#" != 1 ]; then
  echo 'Usage: pnpm data:load --local (fixed local development container only)' >&2
  exit 1
fi
command -v docker >/dev/null 2>&1 || { echo 'BLOCKED: Docker is required; use pnpm test:data:standalone with PostgreSQL 17.' >&2; exit 1; }
pnpm data:generate
docker --host unix:///var/run/docker.sock exec -i supabase_db_ai-fitness-operations-copilot psql -X -U postgres -d postgres -v ON_ERROR_STOP=1 < node_modules/.cache/synthetic-dataset/dataset.sql
