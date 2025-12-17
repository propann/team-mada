#!/usr/bin/env bash
set -euo pipefail

MODE=${1:-}
DATE_TAG=$(date +%Y%m%d-%H%M%S)

if [[ -z "$MODE" ]]; then
  echo "Usage: $0 <postgres|volumes>" >&2
  exit 1
fi

if [[ -f .env ]]; then set -a; source .env; set +a; else set -a; source .env.example; set +a; fi
DATA_ROOT=${DATA_ROOT:-./data}
BACKUP_ROOT=${BACKUP_ROOT:-./backups}
TENANTS_LIST=${TENANTS:-"azoth maximus koff"}

mkdir -p "$BACKUP_ROOT"

case "$MODE" in
  postgres)
    mkdir -p "$BACKUP_ROOT/postgres"
    for tenant in $TENANTS_LIST; do
      FILE="$BACKUP_ROOT/postgres/${tenant}-${DATE_TAG}.sql.gz"
      echo "Dumping postgres for $tenant -> $FILE"
      docker compose exec -T "postgres-$tenant" pg_dumpall -U "$POSTGRES_USER" | gzip > "$FILE"
    done
    ;;
  volumes)
    mkdir -p "$BACKUP_ROOT/volumes"
    ARCHIVE="$BACKUP_ROOT/volumes/volumes-${DATE_TAG}.tar.gz"
    echo "Archiving volumes to $ARCHIVE"
    tar -czf "$ARCHIVE" "$DATA_ROOT"
    ;;
  *)
    echo "Unknown mode: $MODE" >&2
    exit 1
    ;;
fi

echo "Backup completed ($MODE)."
