# Prometheus – attrapeur de métriques

Prometheus scrute vos services sur le réseau interne.

## Configuration
- Port : `127.0.0.1:9090`
- Fichier de config : `data/shared/prometheus/prometheus.yml` (copiez votre propre scrape_config si besoin).

## Cibles de base
- `http://grafana:3000/metrics`
- `http://n8n-<tenant>:5678/metrics`
- `http://qdrant-<tenant>:6333/metrics` (si activé)

## Tips
- Ajoutez `external_labels` pour identifier l’instance (utile si vous poussez vers Thanos).
- Testez vos requêtes dans l’onglet **Graph** avant de les envoyer à Grafana. PromQL ne mord pas (sauf si vous tapez `rate()` sans intervalle...)
