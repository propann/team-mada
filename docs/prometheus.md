# Prometheus

## Rôle
Collecte de métriques et moteur de requêtes pour le monitoring.

## Dépendances
- Fichier de configuration `configs/prometheus.yml` (scrape n8n + self). Ajoutez vos cibles dans `static_configs`.

## Ports
- 9090 (HTTP) lié à 127.0.0.1 par défaut.

## Volumes
- Mono-instance : `prometheus_data` → `/prometheus`
- Multi-tenant : `./data/shared/prometheus` → `/prometheus`
- Config : `configs/prometheus.yml` → `/etc/prometheus/prometheus.yml`

## Risques sécurité
- Interface d’admin exposée si proxy ouvert sans auth.
- Cibles en clair sur le réseau interne (ajouter TLS côté exporter si nécessaire).

## Configuration recommandée
- Garder le port local ; passer par reverse proxy si exposition nécessaire.
- Limiter la rétention via flags Prometheus si le volume disque est restreint (non défini par défaut).
- Recharger la config à chaud : `docker compose exec prometheus kill -HUP 1` ou via l’API `/-/reload` si `--web.enable-lifecycle`.

## Vérification rapide
```
docker compose -f compose/stack.yml ps prometheus
curl -fsSL http://127.0.0.1:${PROMETHEUS_PORT:-9090}/-/healthy
```
