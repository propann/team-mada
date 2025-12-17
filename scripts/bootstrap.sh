#!/usr/bin/env bash
set -euo pipefail

# Load env (prefer .env, fall back to example)
if [[ -f .env ]]; then
  set -a; source .env; set +a
elif [[ -f .env.example ]]; then
  set -a; source .env.example; set +a
else
  echo "No .env or .env.example found" >&2
  exit 1
fi

DATA_ROOT=${DATA_ROOT:-./data}
BACKUP_ROOT=${BACKUP_ROOT:-./backups}
TENANTS_LIST=${TENANTS:-"azoth maximus koff"}

mkdir -p "$BACKUP_ROOT"/postgres "$BACKUP_ROOT"/volumes "$BACKUP_ROOT"/workflows "$BACKUP_ROOT"/grafana
mkdir -p "$DATA_ROOT"/shared/{mqtt,ai-proxy,prometheus,grafana,embed-service,strudel}

for tenant in $TENANTS_LIST; do
  mkdir -p "$DATA_ROOT/$tenant"/{n8n,postgres,qdrant,minio}
  # Redis keeps its data in memory, folder mostly for future dumps/configs
  mkdir -p "$DATA_ROOT/$tenant/redis"
  echo "Prepared directories for tenant: $tenant"
done

chmod -R 750 "$DATA_ROOT" "$BACKUP_ROOT"
echo "Bootstrap complete. You can now run: docker compose up -d"
