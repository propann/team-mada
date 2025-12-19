# 05 — Configuration

## Fichiers clés
- `.env` : variables principales (ports, identifiants, clés API). Basé sur `.env.example`.
- `configs/mqtt/acl` : règles d'accès par topic.
- `configs/mqtt/passwords` : utilisateurs MQTT (format `user:password` généré via `mosquitto_passwd`).
- `configs/mqtt/certs/` : certificats TLS MQTT (non versionnés).
- `configs/prometheus.yml` : cibles de scraping Prometheus.
- `configs/reverse-proxy/` : configuration Caddy (optionnel).

## Variables essentielles (`.env`)
- Identité : `PROJECT_NAME`, `TZ`.
- Réseaux/ports : `N8N_PORT`, `N8N_WEBHOOK_PORT`, `GRAFANA_PORT`, `PROMETHEUS_PORT`, `MOSQUITTO_PORT`, `MQTT_TLS_PORT`, `MINIO_API_PORT`, `MINIO_CONSOLE_PORT`, `QDRANT_PORT`, `STRUDEL_PORT`, `AI_PROXY_PORT`, `EMBED_SERVICE_PORT`.
- Bases : `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`, `REDIS_PASSWORD`.
- Stockage : `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD`.
- n8n : `N8N_BASIC_AUTH_USER`, `N8N_BASIC_AUTH_PASSWORD`, `N8N_ENCRYPTION_KEY`, `N8N_SECURE_COOKIE`.
- Qdrant : `QDRANT_API_KEY`.
- Reverse proxy : `PUBLIC_DOMAIN=YOUR_DOMAIN`, `EMAIL_LETSENCRYPT=ops@YOUR_DOMAIN`, `ENABLE_REVERSE_PROXY` (true/false).
- AI proxy : `GROQ_API_KEY=YOUR_TOKEN` (à injecter via secrets, pas en clair dans Git).

## Bonnes pratiques
- Remplacer tous les `CHANGE_ME` et placeholders avant démarrage.
- Conserver `.env` hors Git ; utiliser un secret manager ou un dépôt privé chiffré.
- Pour MQTT, générer les utilisateurs :
  ```bash
  docker compose -f compose/stack.yml exec mosquitto \
    mosquitto_passwd -b /mosquitto/config/passwords <user> <motdepasse>
  ```
- Pour la TLS MQTT, déposer vos certificats dans `configs/mqtt/certs/` avec permissions restrictives (`600`).
- Si vous changez des ports, mettre à jour la configuration Grafana/Prometheus/n8n en conséquence.

## Fichiers à ne pas versionner
- `.env`, dumps `backups/`, certificats `*.crt/*.key`, artefacts de logs. Vérifier `.gitignore` après ajout de nouveaux fichiers sensibles.
