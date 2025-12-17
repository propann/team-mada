# Grafana – tableau de bord avec café

Grafana affiche vos métriques et dashboards multi-tenant (ou pas). Les données proviennent de Prometheus et, au besoin, d’autres sources.

## Accès
- URL : `http://127.0.0.1:3000`
- Login par défaut : `admin / change-me` (à modifier immédiatement dans les paramètres de sécurité).

## Datasources recommandées
- Prometheus : `http://prometheus:9090`
- PostgreSQL par tenant : `postgres-<tenant>:5432` (utilisez des comptes en lecture seule si possible).

## Dashboards utiles
- Santé n8n : surveillez `n8n_active_executions` et la latence des webhooks.
- MinIO : importez un dashboard S3 générique pour suivre le trafic.
- Qdrant : métriques d’API et latence de recherche.

## Astuces
- Activez `anonymous` uniquement derrière un reverse-proxy authentifiant.
- Exportez vos dashboards JSON dans `backups/grafana/` pour versionner votre art.
