#!/bin/sh
# Disposable real PostgreSQL: no supplied connection URL, no existing database reset.
set -eu
cd "$(dirname "$0")/../.."
case "${1-}" in
  '') [ "$#" = 0 ] || exit 1 ;;
  --synthetic-data) [ "$#" = 1 ] || exit 1 ;;
  *) echo 'Usage: standalone.sh [--synthetic-data]' >&2; exit 1 ;;
esac
for binary in initdb pg_ctl psql createdb pg_dump; do
  command -v "$binary" >/dev/null 2>&1 || { echo "BLOCKED: PostgreSQL 17 $binary must be on PATH." >&2; exit 1; }
done
case "$(initdb --version)" in
  *' 17.'*) ;;
  *) echo 'PostgreSQL 17 is required to match supabase/config.toml.' >&2; exit 1 ;;
esac
# Ignore inherited libpq settings; the only target is this freshly created cluster.
unset PGHOST PGHOSTADDR PGPORT PGDATABASE PGUSER PGPASSWORD PGPASSFILE PGSERVICE PGSERVICEFILE PGOPTIONS
mkdir -p node_modules/.cache
work_dir=$(mktemp -d "$PWD/node_modules/.cache/db-test.XXXXXX")
socket_dir=$(mktemp -d /tmp/fitness-db-socket.XXXXXX)
cleanup() {
  pg_ctl -D "$work_dir/data" -m immediate -w stop >/dev/null 2>&1 || true
  rm -rf "$work_dir" "$socket_dir"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
initdb -D "$work_dir/data" -U postgres --auth=trust --no-locale --encoding=UTF8 > "$work_dir/init.log"
pg_ctl -D "$work_dir/data" -l "$work_dir/server.log" -o "-c listen_addresses='' -c unix_socket_directories='$socket_dir' -c timezone=UTC" -w start >/dev/null
export PGHOST="$socket_dir" PGPORT=5432 PGUSER=postgres
for cycle in 1 2; do
  export PGDATABASE="foundation_$cycle"
  createdb "$PGDATABASE"
  bootstrap_file=scripts/database/standalone-bootstrap.sql
  if [ "$cycle" = 2 ]; then bootstrap_file="$work_dir/bootstrap-second.sql"; fi
  psql -X -v ON_ERROR_STOP=1 -f "$bootstrap_file" > "$work_dir/bootstrap-$cycle.log" 2>&1 || { cat "$work_dir/bootstrap-$cycle.log"; exit 1; }
  for migration in supabase/migrations/*.sql; do
    echo "Apply $migration (clean database $cycle)"
    psql -X -1 -v ON_ERROR_STOP=1 -f "$migration" > "$work_dir/migration.log" 2>&1 || { cat "$work_dir/migration.log"; exit 1; }
  done
  for test_file in supabase/tests/database/*.sql; do
    psql -X -v ON_ERROR_STOP=1 -f "$test_file"
  done
  if [ "${1-}" = '--synthetic-data' ]; then
    seed_file=node_modules/.cache/synthetic-dataset/dataset.sql
    for repetition in 1 2; do
      psql -X -v ON_ERROR_STOP=1 -f "$seed_file" > "$work_dir/seed.log" 2>&1 || { cat "$work_dir/seed.log"; exit 1; }
      psql -X -v ON_ERROR_STOP=1 -f scripts/data/database.test.sql > "$work_dir/seed-test.log" 2>&1 || { cat "$work_dir/seed-test.log"; exit 1; }
      # Explicit order, all columns: reruns must preserve timestamps and historical rows too.
      for table in gym_units members access_records; do
        psql -X -At -c "SELECT row_to_json(t) FROM public.$table t ORDER BY id"
      done > "$work_dir/data-$cycle-$repetition.jsonl"
    done
    cmp "$work_dir/data-$cycle-1.jsonl" "$work_dir/data-$cycle-2.jsonl"
    if [ "$cycle" = 2 ]; then cmp "$work_dir/data-1-1.jsonl" "$work_dir/data-2-1.jsonl"; fi
    cat "$work_dir/seed-test.log"
    # A legitimate historical void must never be silently restored by reseeding.
    psql -X -v ON_ERROR_STOP=1 -c "UPDATE public.access_records SET status = 'VOIDED', voided_at = '2026-09-19T03:00:00Z' WHERE id = (SELECT id FROM public.access_records WHERE status = 'VALID' ORDER BY id LIMIT 1)" > /dev/null
    psql -X -At -c 'SELECT row_to_json(t) FROM public.access_records t ORDER BY id' > "$work_dir/drift-before.jsonl"
    if psql -X -v ON_ERROR_STOP=1 -f "$seed_file" > "$work_dir/drift.log" 2>&1; then
      echo 'FAIL: reseeding must reject changed historical facts' >&2; exit 1
    fi
    case "$(cat "$work_dir/drift.log")" in
      *'Existing access_records differs from deterministic seed'*) ;;
      *) cat "$work_dir/drift.log"; exit 1 ;;
    esac
    psql -X -At -c 'SELECT row_to_json(t) FROM public.access_records t ORDER BY id' > "$work_dir/drift-after.jsonl"
    cmp "$work_dir/drift-before.jsonl" "$work_dir/drift-after.jsonl"
    echo 'PASS: seed loads twice identically, tenant denial, Golden counts, drift rejected without rewriting facts.'
  fi
  pg_dump --schema-only --schema=public --schema=private --schema=api --no-owner --no-privileges | sed '/^\\restrict /d; /^\\unrestrict /d' > "$work_dir/schema-$cycle.sql"
  # Roles are cluster-scoped; retain them for the second database bootstrap.
  if [ "$cycle" = 1 ]; then
    sed '/^CREATE ROLE /d' scripts/database/standalone-bootstrap.sql > "$work_dir/bootstrap-second.sql"
  fi
done
cmp "$work_dir/schema-1.sql" "$work_dir/schema-2.sql"
echo 'PASS: two clean databases, identical schemas, real PostgreSQL constraints and RLS.'
