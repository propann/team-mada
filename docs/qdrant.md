# Qdrant

## Rôle
Base de vecteurs pour la recherche sémantique ou les features IA utilisées par certains workflows.

## Dépendances
- Stockage persistant via volume.
- Réseau interne (`koff_net` + `backbone_net` dans la stack par défaut, par tenant dans la variante multi-tenant).

## Ports
- 6333 (HTTP/gRPC) lié à 127.0.0.1 par défaut (ports dédiés par tenant en multi-tenant).

## Volumes
- Mono-instance : `qdrant_data` → `/qdrant/storage`
- Multi-tenant : `./data/<tenant>/qdrant` → `/qdrant/storage`

## Risques sécurité
- Pas d’auth si `QDRANT_API_KEY` vide.
- Exposition réseau permettant la suppression ou l’exfiltration d’index.

## Configuration recommandée
- Définir `QDRANT_API_KEY` dans `.env` et référencer la clé côté clients.
- Conserver le binding local + réseau interne ; ne pas publier le port en Internet sans proxy/auth.
- Planifier des sauvegardes d’instantanés (snapshots Qdrant) si les vecteurs sont critiques.

## Vérification rapide
```
docker compose -f compose/stack.yml ps qdrant
curl -fsSL http://127.0.0.1:${QDRANT_PORT:-6333}/collections | head -n 5
```
