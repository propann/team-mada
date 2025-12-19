#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/compose/stack.yml}"

if ! docker compose -f "$COMPOSE_FILE" ps >/dev/null; then
  echo "Docker Compose ne répond pas." >&2
  exit 1
fi

services=(postgres redis mosquitto n8n grafana prometheus qdrant minio strudel ai-proxy jeux-text embed-service)
for svc in "${services[@]}"; do
  if docker compose -f "$COMPOSE_FILE" ps --status running "$svc" | grep -q "$svc"; then
    echo "[OK] $svc en cours d'exécution"
  else
    echo "[WARN] $svc non démarré" >&2
  fi
done

echo "Tests HTTP locaux"
curl -fsS http://127.0.0.1:${N8N_PORT:-5678}/healthz || echo "n8n indisponible"
curl -fsS http://127.0.0.1:${PROMETHEUS_PORT:-9090}/-/healthy || echo "prometheus indisponible"
