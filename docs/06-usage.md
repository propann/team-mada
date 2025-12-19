# 06 — Usage

## Cas d'usage typiques
- 🚀 **Workflows n8n** : orchestrer des intégrations, appels API, transferts de fichiers via MinIO, publications MQTT.
- 📡 **IoT / temps réel** : collecter capteurs via MQTT, router vers n8n ou stocker dans Postgres.
- 🔍 **Recherche vectorielle** : générer des embeddings (via embed-service ou service externe) puis indexer dans Qdrant.
- 🖼️ **Apps internes** : exposer ai-proxy/statique et Strudel via ingress pour tests UX/AV.

## Commandes utiles
- Lister l'état :
  ```bash
  docker compose -f compose/stack.yml ps
  ```
- Logs temps réel :
  ```bash
  docker compose -f compose/stack.yml logs -f <service>
  ```
- Ajouter une dépendance n8n (ex: module npm dans `n8n_data`) : monter le volume, installer, puis redémarrer n8n.
- Tester MQTT :
  ```bash
  docker compose -f compose/stack.yml exec mosquitto \
    mosquitto_sub -t 'health' -C 1 -i test-client
  ```
- Vérifier Prometheus : http://127.0.0.1:${PROMETHEUS_PORT}
- Importer un dashboard Grafana : utiliser l'UI, garder les datasources sans secrets hardcodés.

## Cycle de vie
- **Démarrer** : `docker compose -f compose/stack.yml up -d`
- **Arrêter** : `docker compose -f compose/stack.yml down`
- **Mettre à jour les images** :
  ```bash
  docker compose -f compose/stack.yml pull
  docker compose -f compose/stack.yml up -d
  ```
- **Rollback Postgres** : restaurer un dump via `scripts/restore.sh` (stack démarrée).

## Tests rapides de santé
- `scripts/healthcheck.sh` (si fourni) pour vérifier ports et endpoints internes.
- `docker compose -f compose/stack.yml exec n8n curl -f http://localhost:5678/healthz` pour n8n.
- `mosquitto_sub` sur le topic `health` pour vérifier le broker.
