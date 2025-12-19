# 04 — Installation propre

## 1) Préparer l'hôte
```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
```

## 2) Installer Docker Engine + Compose v2
```bash
# Repo officiel Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \ 
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release; echo \"$ID\") \"$(lsb_release -cs)\" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
> ℹ️ Vérifiez `docker --version` et `docker compose version`.

## 3) Cloner le dépôt
```bash
git clone https://YOUR_DOMAIN/team-mada.git
cd team-mada
```

## 4) Bootstrap
```bash
./scripts/bootstrap.sh
```
- Génère `.env` à partir du template.
- Crée `backups/`, `logs/`, `configs/mqtt/certs/`, `data/shared`.

## 5) Configurer
- Ouvrir `.env` et remplacer tous les `CHANGE_ME`, `example.com`, `YOUR_TOKEN`.
- Ajuster les ports si besoin (conflits locaux).
- Préparer les fichiers :
  - `configs/mqtt/acl` et `configs/mqtt/passwords` (utilisateurs + ACL spécifiques).
  - Certificats MQTT optionnels dans `configs/mqtt/certs/` (`ca.crt`, `server.crt`, `server.key`).
  - Si reverse proxy : config Caddy dans `configs/reverse-proxy/Caddyfile` (placeholder `YOUR_DOMAIN`).

## 6) Démarrer la stack
```bash
docker compose -f compose/stack.yml up -d
# ou
docker compose -f compose/multi-tenant.yml up -d
```
Option HTTPS :
```bash
docker compose \
  -f compose/stack.yml \
  -f compose/reverse-proxy.caddy.yml \
  up -d
```

## 7) Vérifier
```bash
docker compose -f compose/stack.yml ps
docker compose -f compose/stack.yml logs --tail 50
```

## 8) Accès initiaux (local/VPN)
- n8n : http://127.0.0.1:${N8N_PORT}
- Grafana : http://127.0.0.1:${GRAFANA_PORT}
- MinIO console : http://127.0.0.1:${MINIO_CONSOLE_PORT}
- MQTT : `127.0.0.1:${MOSQUITTO_PORT}` (TLS sur `${MQTT_TLS_PORT}`)

> ⚠️ **WARNING** : ne pas exposer ces ports en 0.0.0.0. Utiliser un VPN ou le reverse proxy avec authentification.
