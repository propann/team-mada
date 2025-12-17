# MinIO

## Rôle
Stockage objet compatible S3 pour sauvegardes, artefacts et échanges inter-services.

## Dépendances
- Volume `minio_data`.
- Réseau `backbone_net`.

## Ports
- 9000 (API) – bind 127.0.0.1 par défaut.
- 9001 (console) – bind 127.0.0.1 par défaut.

## Volumes
- `minio_data` → `/data`

## Risques sécurité
- Identifiants root nécessaires : ne jamais les versionner.
- Console accessible : limiter à localhost ou protéger via reverse proxy.

## Configuration recommandée
- Remplir `MINIO_ROOT_USER` et `MINIO_ROOT_PASSWORD` via `.env`.
- Créer des policies minimales par bucket.
- Activer le chiffrage côté serveur (`sse`) si besoin via variables supplémentaires.

## Vérification rapide
```
curl -fsS http://127.0.0.1:${MINIO_API_PORT:-9000}/minio/health/ready
```
