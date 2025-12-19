# 07 — Maintenance

## Sauvegarde
- Postgres :
  ```bash
  ./scripts/backup.sh
  ```
  → dump compressé dans `backups/postgres/`.
- MinIO/Qdrant : prévoir des sauvegardes volume-level (snapshot disque ou `docker run --rm` avec `tar`), non fournies ici.

## Restauration
```bash
./scripts/restore.sh backups/postgres/<dump>.sql.gz
```
- Vérifier que la stack tourne et que les variables DB correspondent au dump.

## Mise à jour
```bash
docker compose -f compose/stack.yml pull
docker compose -f compose/stack.yml up -d
```
- Refaire la commande avec `multi-tenant.yml` si vous utilisez la variante.
- Vérifier les notes de version des images épinglées avant upgrade.

## Logs et diagnostic
- Logs d'un service : `docker compose -f compose/stack.yml logs -f <service>`
- Santé n8n : `curl -f http://127.0.0.1:${N8N_PORT}/healthz`
- Santé Mosquitto : `mosquitto_sub -t 'health' -C 1 -W 3`
- Vérifier ressources : `docker stats`

## Nettoyage
- Arrêt complet : `docker compose -f compose/stack.yml down`
- Suppression volumes (⚠️ destructif) : `docker compose -f compose/stack.yml down -v`
- Rotation logs : ajuster `max-size`/`max-file` dans les options de logging Compose si besoin.

## Supervision continue
- Ajouter des alertes Prometheus/Grafana (non fournies) pour surveiller CPU, mémoire, espace disque et disponibilité des endpoints.
- Planifier un cron/systemd timer pour `./scripts/backup.sh` et vérifier les retours.
