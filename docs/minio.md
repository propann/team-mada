# MinIO – les seaux organisés

Chaque tenant reçoit son instance MinIO, pour des buckets propres et secs.

## Accès
- azoth : API `127.0.0.1:9000`, console `127.0.0.1:9001`
- maximus : API `127.0.0.1:9020`, console `127.0.0.1:9021`
- koff : API `127.0.0.1:9040`, console `127.0.0.1:9041`
- Credentials : `.env` (`MINIO_ROOT_USER` / `MINIO_ROOT_PASSWORD`).

## Bucket naming
- Utilisez un bucket par tenant : `azoth-bucket`, `maximus-bucket`, `koff-bucket`.
- Activez le versioning si vos workflows n8n manipulent des fichiers critiques.

## Sauvegarde
- `bash scripts/backup.sh volumes` crée une archive incluant les données MinIO.
- Pour un dump ciblé : `mc mirror minio-azoth/<bucket> backups/minio/azoth/<bucket>`.

## Restauration rapide
- `bash scripts/restore.sh volumes backups/minio-azoth-YYYYMMDD.tar.gz`
- Ou `mc mirror backups/minio/... minio-azoth/<bucket>` si vous aimez les aller-retours.
