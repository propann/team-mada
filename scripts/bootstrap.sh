#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

command -v docker >/dev/null 2>&1 || { echo "Docker manquant"; exit 1; }
command -v docker compose >/dev/null 2>&1 || { echo "Docker Compose v2 manquant"; exit 1; }

mkdir -p "$PROJECT_ROOT/backups/postgres" "$PROJECT_ROOT/logs" "$PROJECT_ROOT/configs/mqtt/certs"

if [[ ! -f "$ENV_FILE" ]]; then
  cp "$PROJECT_ROOT/.env.example" "$ENV_FILE"
  echo "Fichier .env créé depuis .env.example. Pensez à le personnaliser."
fi

chown "${LOCAL_UID:-1000}:${LOCAL_GID:-1000}" "$PROJECT_ROOT/backups" "$PROJECT_ROOT/logs" 2>/dev/null || true
chmod 750 "$PROJECT_ROOT/backups" "$PROJECT_ROOT/logs"

echo "Bootstrap terminé. Lancez 'docker compose -f compose/docker-compose.yml up -d'."
