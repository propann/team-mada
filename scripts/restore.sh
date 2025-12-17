#!/usr/bin/env bash
set -euo pipefail

MODE=${1:-}
TARGET=${2:-}
FILE=${3:-}

if [[ -z "$MODE" ]]; then
  echo "Usage: $0 <postgres tenant dump.sql.gz | volumes archive.tar.gz>" >&2
  exit 1
fi

if [[ -f .env ]]; then set -a; source .env; set +a; else set -a; source .env.example; set +a; fi
DATA_ROOT=${DATA_ROOT:-./data}

case "$MODE" in
  postgres)
    if [[ -z "$TARGET" || -z "$FILE" ]]; then
      echo "Usage: $0 postgres <tenant> <dump.sql.gz>" >&2
      exit 1
    fi
    echo "Restoring postgres for $TARGET from $FILE"
    gunzip -c "$FILE" | docker compose exec -T "postgres-$TARGET" psql -U "$POSTGRES_USER"
    ;;
  volumes)
    ARCHIVE=${TARGET}
    if [[ ! -f "$ARCHIVE" ]]; then
      echo "Archive not found: $ARCHIVE" >&2
      exit 1
    fi
    echo "Stopping services before restore..."
    docker compose down
    echo "Restoring volumes from $ARCHIVE"
    tar -xzf "$ARCHIVE" -C ./
    echo "Restarting services"
    docker compose up -d
    ;;
  *)
    echo "Unknown mode: $MODE" >&2
    exit 1
    ;;
fi

echo "Restore completed ($MODE)."
