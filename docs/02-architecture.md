# 02 — Architecture

## Diagramme ASCII (stack standard)
```
                  [ Clients internes / VPN ]
                           |
                     ingress_net
                   /      |       \
          ai-proxy   embed-service   jeux-text
             |             |              |
           koff_net     koff_net      ingress_net
               \            |           /
                \        koff_net     /
                 \         |        /
                  \     backbone_net
                      /     |     \
                 mosquitto  qdrant  minio
                       \      |      /
                        \   backbone_net
                          \    |
                           postgres —— redis
                               |
                           azoth_net (n8n)
                               |
                         n8n (workflows)

                   monitoring_net (interne)
                       /                 \
                 prometheus           grafana
```

## Variante multi-tenant
- Compose `compose/multi-tenant.yml` duplique n8n/Postgres/Redis/MQTT par tenant (`azoth`, `maximus`, `koff`) avec réseaux dédiés.
- Les services partagés (Prometheus, Grafana, Strudel, Qdrant, MinIO) restent uniques mais connectés aux réseaux nécessaires.

## Flux réseau
- **Ingress** : `ingress_net` sert de façade interne (ai-proxy, embed-service, jeux-text, Strudel). Si Caddy est activé, il s'accroche aussi sur ce réseau.
- **Backbone** : `backbone_net` relie les briques data (Postgres, Redis, Qdrant, MinIO, Mosquitto) et n8n.
- **Monitoring** : `monitoring_net` est marqué `internal: true` et relie Prometheus/Grafana.
- **Locaux** : toutes les publications de ports sont bindées sur `127.0.0.1` pour éviter l'exposition involontaire.

## Flux de données
- n8n ↔ Postgres/Redis pour la persistance des workflows et queues.
- n8n ↔ Mosquitto pour publier/consommer des événements MQTT.
- n8n ↔ MinIO pour stocker/servir des fichiers.
- n8n/clients ↔ Qdrant + embed-service pour indexer/requêter des vecteurs.
- Prometheus scrappe les services exposant `/metrics` (selon configuration), Grafana lit Prometheus.
- ai-proxy fait des appels sortants HTTPS vers l'API Groq avec la clé `GROQ_API_KEY` injectée côté environnement.

## Séparation local / VPS / clients
- **Local ou VPS privé** : accès direct via 127.0.0.1 ou tunnel SSH/VPN. Aucun port public ouvert par défaut.
- **Internet** : activer `compose/reverse-proxy.caddy.yml` et n'exposer que 80/443. Configurer `PUBLIC_DOMAIN=YOUR_DOMAIN` + `EMAIL_LETSENCRYPT`. Ajouter authentification forte (basic auth n8n activée via env, proxy d'identité recommandé).
- **Clients MQTT** : se connectent via tunnel/VPN ou via reverse proxy TCP si ajouté (non fourni). TLS possible en déposant vos certificats dans `configs/mqtt/certs/`.
