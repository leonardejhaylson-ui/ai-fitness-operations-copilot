#!/bin/sh
# Disposable real PostgreSQL: no supplied connection URL, no existing database reset.
set -eu
cd "$(dirname "$0")/../.."
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
  pg_dump --schema-only --schema=public --schema=private --schema=api --no-owner --no-privileges | sed '/^\\restrict /d; /^\\unrestrict /d' > "$work_dir/schema-$cycle.sql"
  # Roles are cluster-scoped; retain them for the second database bootstrap.
  if [ "$cycle" = 1 ]; then
    sed '/^CREATE ROLE /d' scripts/database/standalone-bootstrap.sql > "$work_dir/bootstrap-second.sql"
  fi
done
cmp "$work_dir/schema-1.sql" "$work_dir/schema-2.sql"
echo 'PASS: two clean databases, identical schemas, real PostgreSQL constraints and RLS.'
