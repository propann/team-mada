# n8n

## Rôle
Automatisation de workflows (tenant azoth/maximus/koff ou mono-instance) avec stockage Postgres et cache Redis.

## Dépendances
- PostgreSQL (`postgres` ou `postgres-<tenant>`)
- Redis (`redis` ou `redis-<tenant>`)
- Qdrant/MinIO optionnels selon les workflows IA ou stockage objet.
- Reverse proxy si exposition Internet.

## Ports
- UI/API : `5678` (lié à 127.0.0.1 par défaut)
- Webhooks : utiliser `N8N_WEBHOOK_URL` pour refléter l’URL publique si proxy.

## Volumes
- Mono-instance : `n8n_data` → `/home/node/.n8n`
- Multi-tenant : `./data/<tenant>/n8n` → `/home/node/.n8n`

## Risques sécurité
- Exposition des webhooks et de l’UI sans authentification.
- Stockage des credentials non chiffrés si `N8N_ENCRYPTION_KEY` absent.
- Plugins communautaires potentiellement non audités.

## Configuration recommandée
- Activer l’auth basique (`N8N_BASIC_AUTH_ACTIVE=true`, variables utilisateur/mot de passe renseignées).
- Définir `N8N_ENCRYPTION_KEY` et `N8N_SECURE_COOKIE=true`.
- Désactiver télémétrie/diagnostic (`N8N_DIAGNOSTICS_ENABLED=false`).
- Utiliser le reverse proxy pour HTTPS et rate-limit ; limiter l’ouverture réseau (ports liés à 127.0.0.1).
- Monter `/tmp` en `tmpfs` (déjà configuré) pour limiter les écritures disque temporaires.

## Vérification rapide
```
docker compose -f compose/stack.yml ps n8n
curl -fsSL http://127.0.0.1:${N8N_PORT:-5678}/healthz
```
