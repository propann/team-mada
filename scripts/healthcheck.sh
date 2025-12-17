#!/usr/bin/env bash
set -euo pipefail

if [[ -f .env ]]; then set -a; source .env; set +a; else set -a; source .env.example; set +a; fi
TENANTS_LIST=${TENANTS:-"azoth maximus koff"}
RETRIES=${HEALTHCHECK_RETRIES:-5}
TIMEOUT=${HEALTHCHECK_TIMEOUT:-3}

check_http() {
  local name="$1" url="$2"
  echo -n "- $name ($url): "
  if curl -fsSL --max-time "$TIMEOUT" "$url" >/dev/null; then
    echo "OK"
  else
    echo "KO"
  fi
}

# Container status
for svc in $(docker compose ps --services); do
  id=$(docker compose ps -q "$svc")
  if [[ -z "$id" ]]; then
    echo "Service $svc not running"
    continue
  fi
  if ! docker inspect --format='{{.State.Health.Status}}' "$id" 2>/dev/null | grep -q healthy; then
    state=$(docker inspect --format='{{.State.Status}}' "$id")
    echo "Service $svc state: $state"
  else
    echo "Service $svc healthy"
  fi
done

# HTTP endpoints
for tenant in $TENANTS_LIST; do
  case "$tenant" in
    azoth) idx=1 ;;
    maximus) idx=2 ;;
    koff) idx=3 ;;
    *) idx=9 ;;
  esac
  n8n_port="56${idx}8"
  qdrant_port="63${idx}3"
  minio_port="90${idx}0"
  check_http "n8n-$tenant" "http://127.0.0.1:${n8n_port}/healthz" || true
  check_http "qdrant-$tenant" "http://127.0.0.1:${qdrant_port}" || true
  check_http "minio-$tenant" "http://127.0.0.1:${minio_port}/minio/health/live" || true
done

check_http grafana "http://127.0.0.1:${GRAFANA_PORT:-3000}/api/health" || true
check_http prometheus "http://127.0.0.1:${PROMETHEUS_PORT:-9090}/-/ready" || true
check_http ai-proxy "http://127.0.0.1:${AI_PROXY_PORT:-8081}" || true
check_http embed-service "http://127.0.0.1:${EMBED_SERVICE_PORT:-8082}" || true
MQTT_PORT_HOST=${MQTT_PORT:-1883}
echo -n "- mqtt (tcp:${MQTT_PORT_HOST}): "
if nc -z 127.0.0.1 "${MQTT_PORT_HOST}"; then
  echo "OK"
else
  echo "KO"
fi
