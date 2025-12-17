# Embed Service

## Rôle
Service HTTP statique simple pour exposer des embeddings ou des fichiers modèle via HTTP.

## Dépendances
- Aucun service interne ; réseaux `koff_net` + `ingress_net`.

## Ports
- 8082 (HTTP) lié à 127.0.0.1.

## Volumes
- Mono-instance : `./data/shared/embed-service` → `/srv/app` (read-only).
- Multi-tenant : même volume partagé.

## Risques sécurité
- Aucun mécanisme d’authentification intégré.
- Si le volume est modifiable par d’autres services, risque de substitution de modèle.

## Configuration recommandée
- Laisser `read_only: true` pour le conteneur.
- Passer par le reverse proxy si exposition externe (TLS + auth).
- Stocker les fichiers volumineux hors dépôt et documenter leur provenance/empreinte.

## Vérification rapide
```
docker compose -f compose/stack.yml ps embed-service
curl -I http://127.0.0.1:${EMBED_SERVICE_PORT:-8082}/
```
