# Redis

## Rôle
Cache et moteur de file d’attente Bull pour n8n.

## Dépendances
- Aucun service externe ; partage le réseau `backbone_net`.

## Ports
- 6379 interne ; lié sur `127.0.0.1` dans les stacks fournies (un port par tenant en multi-tenant).

## Volumes
- Mono-instance : `redis_data` → `/data`
- Multi-tenant : `./data/<tenant>/redis` si nécessaire (non créé par défaut pour limiter la persistance).

## Risques sécurité
- Accès sans mot de passe si `REDIS_PASSWORD` vide.
- Exposition réseau publique permettant des attaques non authentifiées.

## Configuration recommandée
- Définir `REDIS_PASSWORD` dans `.env` ; le service applique `--requirepass` lorsqu’il est présent.
- Garder le binding sur `127.0.0.1` et le réseau interne Docker.
- Ajouter une politique d’expiration adaptée pour éviter le remplissage disque (selon usages Bull).

## Vérification rapide
```
docker compose -f compose/stack.yml ps redis
docker compose -f compose/stack.yml exec redis redis-cli -a ${REDIS_PASSWORD:-} ping
```
