# MinIO

## Rôle
Stockage objet compatible S3 utilisé par les workflows (backups, assets, exports IA).

## Dépendances
- Aucun service interne ; ports locaux et volume pour la persistance.

## Ports
- 9000 (API S3) lié à 127.0.0.1
- 9001 (console) liée à 127.0.0.1

## Volumes
- Mono-instance : `minio_data` → `/data`
- Multi-tenant : `./data/<tenant>/minio` → `/data`

## Risques sécurité
- Compte root par défaut si `MINIO_ROOT_USER/MINIO_ROOT_PASSWORD` vides.
- Console exposée sans TLS si publiée sur Internet.

## Configuration recommandée
- Renseigner les variables root dans `.env`, créer des utilisateurs/buckets dédiés par application.
- Garder le binding local et placer un reverse proxy TLS si exposition requise.
- Activer le versioning/replication selon la criticité des données (non configuré par défaut).

## Vérification rapide
```
docker compose -f compose/stack.yml ps minio
curl -I http://127.0.0.1:${MINIO_CONSOLE_PORT:-9001}/minio/health/ready
```
