# PostgreSQL

## Rôle
Base de données principale pour n8n et services internes.

## Dépendances
- Stockage persistant `postgres_data`.
- Réseau `backbone_net` (et `azoth_net` pour isolation multi-tenant).

## Ports
- Aucun port publié. Service accessible uniquement via réseau Docker interne (`5432`).

## Volumes
- `postgres_data` → `/var/lib/postgresql/data`
- `./configs/postgres/init` → `/docker-entrypoint-initdb.d`

## Risques sécurité
- Exposition publique interdite : laisser le service interne uniquement.
- Mots de passe faibles ou manquants compromettent l'ensemble de la stack.
- Sauvegardes contenant des données sensibles : chiffrer en dehors du dépôt.

## Configuration recommandée
- Utiliser des mots de passe forts via `.env` (non versionné).
- Activer `pg_hba.conf` restrictif si vous étendez la config (limiter aux réseaux Docker).
- Mettre en place des sauvegardes régulières (script `backup.sh`).

## Vérification rapide
```
docker compose exec postgres pg_isready -U ${POSTGRES_USER:-postgres}
```
