# PostgreSQL

## Rôle
Base de données principale pour n8n et services associés.

## Dépendances
- Stockage persistant sur volume ou dossier host.
- Réseau interne Docker (aucune dépendance externe).

## Ports
- 5432 interne ; lié sur `127.0.0.1` uniquement dans les stacks fournies (un port distinct par tenant dans la variante multi-tenant).

## Volumes
- Mono-instance : `postgres_data` → `/var/lib/postgresql/data`
- Multi-tenant : `./data/<tenant>/postgres` → `/var/lib/postgresql/data`

## Risques sécurité
- Exposition réseau non filtrée (éviter les bindings publics).
- Mots de passe faibles ou partagés entre tenants.
- Absence de sauvegardes régulières.

## Configuration recommandée
- Renseigner `POSTGRES_USER`/`POSTGRES_PASSWORD` dans `.env` (valeurs uniques par environnement).
- Restreindre l’accès au réseau interne Docker uniquement (déjà configuré).
- Activer la journalisation côté container via `logging` (limite taille) pour éviter le remplissage disque.
- Planifier des sauvegardes via `scripts/backup.sh` et des restaurations testées.

## Vérification rapide
```
docker compose -f compose/stack.yml ps postgres
docker compose -f compose/stack.yml exec postgres pg_isready -U ${POSTGRES_USER:-postgres}
```
