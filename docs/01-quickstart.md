# 01 — Quickstart (10 minutes)

## Prérequis
- Docker Engine + Docker Compose v2 installés.
- Accès SSH/console sur l'hôte (Debian/Ubuntu recommandé).
- Ports 80/443 libres si vous activez le reverse proxy.

## Étapes express
1. **Cloner le dépôt**
   ```bash
   git clone https://YOUR_DOMAIN/team-mada.git
   cd team-mada
   ```
2. **Préparer l'environnement**
   ```bash
   ./scripts/bootstrap.sh
   ```
   Créé `.env` depuis `.env.example`, dossiers `backups/`, `logs/` et répertoires MQTT.
3. **Configurer les secrets**
   - Ouvrir `.env` et remplacer tous les `CHANGE_ME`, `example.com`, `YOUR_TOKEN` par vos valeurs.
   - Ne jamais committer `.env` ou des clés TLS.
4. **Choisir la stack**
   - Stack standard : `compose/stack.yml`
   - Variante multi-tenant : `compose/multi-tenant.yml`
   - Reverse proxy HTTPS : ajouter `-f compose/reverse-proxy.caddy.yml` + variables `PUBLIC_DOMAIN`, `EMAIL_LETSENCRYPT`.
5. **Démarrer**
   ```bash
   docker compose -f compose/stack.yml up -d
   # ou
   docker compose -f compose/multi-tenant.yml up -d
   ```
6. **Vérifier**
   ```bash
   docker compose -f compose/stack.yml ps
   docker compose -f compose/stack.yml logs --tail 30
   ```
7. **Accéder (local/VPN)**
   - n8n : http://127.0.0.1:${N8N_PORT}
   - Grafana : http://127.0.0.1:${GRAFANA_PORT}
   - Prometheus : http://127.0.0.1:${PROMETHEUS_PORT}
   - MinIO console : http://127.0.0.1:${MINIO_CONSOLE_PORT}
   - MQTT : `127.0.0.1:${MOSQUITTO_PORT}` (ou TLS sur `${MQTT_TLS_PORT}`)

> 💡 **TIP** : garder la commande `docker compose -f compose/stack.yml logs -f <service>` ouverte pendant les premiers tests.
