# n8n

## Rôle
Automatisation des workflows et orchestration d'intégrations internes.

## Dépendances
- PostgreSQL pour la base de données principale.
- Redis pour la mise en cache et les files temporaires.
- Accès réseau interne via `backbone_net` et `azoth_net`.

## Ports
- HTTP: 5678 (bound to 127.0.0.1 par défaut).

## Volumes
- `n8n_data` → `/home/node/.n8n`

## Risques sécurité
- Exposition des webhooks si le reverse proxy est ouvert sur Internet.
- Plugins et nodes communautaires peuvent introduire du code non maîtrisé.
- Besoin d'une clé d'encryption (`N8N_ENCRYPTION_KEY`) pour protéger les credentials.

## Configuration recommandée
- Activer l'authentification basique (`N8N_BASIC_AUTH_*`).
- Définir `N8N_SECURE_COOKIE=true` et forcer HTTPS via reverse proxy.
- Désactiver la télémétrie et les diagnostics (`N8N_DIAGNOSTICS_ENABLED=false`).
- Placer les webhooks derrière un proxy avec rate limiting (cf. reverse proxy Caddy/Nginx).

## Vérification rapide
```
docker compose ps n8n
curl -fsS http://127.0.0.1:${N8N_PORT:-5678}/healthz
```
