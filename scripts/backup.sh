#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${POSTGRES_BACKUP_DIR:-$PROJECT_ROOT/backups/postgres}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
FILE="$BACKUP_DIR/postgres-$TIMESTAMP.sql.gz"
COMPOSE_FILE="${COMPOSE_FILE:-$PROJECT_ROOT/compose/stack.yml}"

mkdir -p "$BACKUP_DIR"

docker compose -f "$COMPOSE_FILE" exec -T postgres pg_dumpall -U "${POSTGRES_USER:-postgres}" \
  | gzip > "$FILE"

echo "Sauvegarde Postgres créée: $FILE"
