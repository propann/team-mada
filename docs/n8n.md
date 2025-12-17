# n8n – chef d’orchestre des workflows

n8n pilote les automations par tenant. Chaque instance tourne sur son propre PostgreSQL/Redis pour éviter les accidents de cross-posting.

## Connexion
- URL locale : `http://127.0.0.1:5608` (azoth), `5618` (maximus), `5628` (koff).
- Authentification : basic auth via `.env` (`N8N_BASIC_AUTH_USER` / `N8N_BASIC_AUTH_PASSWORD`).

## Secrets & bonnes pratiques
- Renseignez `N8N_ENCRYPTION_KEY` (32 chars) avant le premier démarrage.
- Ajoutez vos API keys via les credentials chiffrés n8n, jamais dans les nodes en clair.
- Utilisez `Environment variables` pour injecter des URLs selon le tenant.

## Petites astuces
- Pour tester un webhook : `curl -X POST http://127.0.0.1:5608/webhook/test`. Oui, on ne juge pas vos payloads JSON.
- Pensez à exporter vos workflows (`.json`) dans le dossier `backups/workflows/`.

## Supervision
- Logs : `docker compose logs n8n-<tenant> -f`.
- Santé Redis : `redis-cli -h redis-<tenant> -a $REDIS_PASSWORD ping` (depuis un conteneur utilitaire).
