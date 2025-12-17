# Qdrant

## Rôle
Base vectorielle pour la recherche sémantique/IA.

## Dépendances
- Volume `qdrant_data`.
- Réseaux `koff_net` et `backbone_net`.

## Ports
- 6333 (HTTP gRPC) – bind 127.0.0.1 par défaut.

## Volumes
- `qdrant_data` → `/qdrant/storage`

## Risques sécurité
- API sans authentification par défaut : garder le service interne ou activer les `api-key` dans la configuration.
- Données vectorielles sensibles (embeddings) : restreindre les exports.

## Configuration recommandée
- Ajouter une clé API via variable d'environnement `QDRANT__SERVICE__API_KEY` (non renseignée ici).
- Utiliser TLS au niveau reverse proxy si exposé.

## Vérification rapide
```
curl -fsS http://127.0.0.1:${QDRANT_PORT:-6333}/ready
```
