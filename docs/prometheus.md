# Prometheus

## Rôle
Collecte et stockage des métriques pour l'observabilité (Grafana).

## Dépendances
- Fichier de configuration `configs/prometheus.yml`.
- Réseau `monitoring_net`.

## Ports
- 9090 (HTTP) – bind 127.0.0.1 par défaut.

## Volumes
- `prometheus_data` → `/prometheus`

## Risques sécurité
- Accès non authentifié par défaut ; conserver l'accès sur localhost ou ajouter un reverse proxy avec auth.
- Cibles de scraping mal protégées peuvent exposer des secrets via métriques.

## Configuration recommandée
- Ajouter des jobs de scraping pour vos exporters en restant sur les réseaux internes.
- Activer `--web.enable-admin-api=false` si vous n'avez pas besoin de reloader à chaud (ici autorisé pour reloader via compose exec).

## Vérification rapide
```
curl -fsS http://127.0.0.1:${PROMETHEUS_PORT:-9090}/-/healthy
```
