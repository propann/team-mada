# 03 — Services

> ℹ️ Les ports sont publiés sur `127.0.0.1` par défaut. Adapter uniquement après revue sécurité.

## Vue rapide
- 🗄️ **Postgres 16** — base n8n, volumes : `postgres_data:/var/lib/postgresql/data`.
- ⚡ **Redis 7** — cache/queues n8n, volume : `redis_data:/data`.
- 📡 **Mosquitto** — broker MQTT, volumes : `configs/mqtt/*` (RO), `mosquitto_data`, `mosquitto_log`. Ports : `${MOSQUITTO_PORT}` / `${MQTT_TLS_PORT}`.
- 🤖 **n8n** — automation, port `${N8N_PORT}`, volume `n8n_data`. Basic auth activée via env.
- 📊 **Grafana** — dashboards, port `${GRAFANA_PORT}`, volume `grafana_data`.
- 📈 **Prometheus** — scraping, port `${PROMETHEUS_PORT}`, volume `prometheus_data`, config `configs/prometheus.yml`.
- 🗂️ **MinIO** — stockage objet, ports `${MINIO_API_PORT}` / `${MINIO_CONSOLE_PORT}`, volume `minio_data`.
- 🧭 **Qdrant** — vecteurs, port `${QDRANT_PORT}`, volume `qdrant_data`, clé API `QDRANT_API_KEY`.
- 🎛️ **Strudel** — app web/AV, port `${STRUDEL_PORT}`.
- 🛰️ **ai-proxy** — serveur HTTP statique + proxy Groq, port `${AI_PROXY_PORT}`, nécessite `GROQ_API_KEY` via env.
- 🪐 **embed-service** — serveur HTTP statique pour embeddings, port `${EMBED_SERVICE_PORT}`.
- 🎮 **jeux-text** — mini-jeu web, santé sur `/health`, exposé via `ingress_net`.
- 🔐 **Reverse proxy (optionnel)** — Caddy, n'exposer que 80/443, fichiers `compose/reverse-proxy.caddy.yml` et `configs/reverse-proxy/`.

## Dépendances clés
- n8n dépend de Postgres + Redis.
- Grafana dépend de Prometheus.
- ai-proxy dépend d'un accès Internet sortant et de `GROQ_API_KEY`.
- Qdrant et embed-service peuvent être utilisés ensemble pour pipeline d'embeddings.

## Points de vigilance
- Toujours personnaliser les ACL MQTT (`configs/mqtt/acl`) et les utilisateurs (`configs/mqtt/passwords`).
- Les ports publics doivent rester fermés sauf reverse proxy. Préférer VPN/tunnel SSH.
- Vérifier les quotas disques des volumes (Postgres, MinIO, Qdrant) avant montée en charge.
