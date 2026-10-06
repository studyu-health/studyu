#!/usr/bin/env bash
set -euo pipefail

yes=false

case "${1:-}" in
  --yes)
    yes=true
    ;;
  "")
    ;;
  *)
    echo "Usage: $0 [--yes]" >&2
    exit 2
    ;;
esac

db_url="${SUPABASE_DB_URL:-postgresql://postgres:postgres@127.0.0.1:54322/postgres}"

apply_sql_file() {
  local file="$1"

  if command -v psql >/dev/null 2>&1; then
    psql "$db_url" -v ON_ERROR_STOP=1 -f "$file"
    return
  fi

  if [[ -n "${SUPABASE_DB_URL:-}" ]]; then
    echo "psql is required when SUPABASE_DB_URL targets a non-local database" >&2
    exit 1
  fi

  docker exec -i supabase_db_studyu psql -U postgres -d postgres -v ON_ERROR_STOP=1 < "$file"
}

if [[ "$yes" != "true" ]]; then
  printf 'This will wipe the local Supabase database and apply test seeds. Continue? [y/N] '
  read -r answer
  case "$answer" in
    y|Y|yes|YES)
      ;;
    *)
      echo "Aborted"
      exit 1
      ;;
  esac
fi

supabase db reset --no-seed

for file in supabase/seeds/test/*.sql; do
  echo "Applying $file"
  apply_sql_file "$file"
done
