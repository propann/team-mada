#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${COMPOSE_FILE:-$PROJECT_ROOT/compose/stack.yml}"

if ! docker compose -f "$COMPOSE_FILE" ps >/dev/null; then
  echo "Stack non démarrée." >&2
  exit 1
fi

echo "Ports exposés sur l'hôte:"
ss -tulpen | grep -E ':(5678|5679|3000|9090|1883|8883|9000|9001|6333|7000|8081|8082)' || echo "Aucun port de la stack exposé ou ports non démarrés."

echo "Containers tournant en root:"
docker compose -f "$COMPOSE_FILE" ps -q | xargs -r docker inspect --format '{{.Name}} -> User={{.Config.User}}' | grep 'User=$' && echo "[WARN] Certains containers tournent en root" || echo "Tous les services définissent un user explicite ou utilisateur par défaut non-root."

echo "Capabilités retirées (cap_drop):"
docker compose -f "$COMPOSE_FILE" config --services | while read -r svc; do
  echo "- $svc:";
  docker compose -f "$COMPOSE_FILE" config | awk "/^  $svc:/,/^[^ ]/" | grep cap_drop || echo "  aucune cap_drop détectée"
done

echo "Volumes en lecture seule (read_only):"
docker compose -f "$COMPOSE_FILE" config --services | while read -r svc; do
  read_only=$(docker compose -f "$COMPOSE_FILE" config | awk "/^  $svc:/,/^[^ ]/" | grep read_only || true)
  if [[ -z "$read_only" ]]; then
    echo "- $svc: pas de filesystem en lecture seule"
  else
    echo "- $svc: read_only activé"
  fi
done

echo "Comptes mosquitto définis (placeholder ok, pas de secrets attendus):"
sed -n '1,3p' "$PROJECT_ROOT/configs/mqtt/passwords"

echo "Variables sensibles (.env) à remplir manuellement:"
grep -E 'PASSWORD|TOKEN|KEY|SECRET' "$PROJECT_ROOT/.env.example" || true
