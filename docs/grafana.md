# Grafana

## Rôle
Visualisation et tableaux de bord pour le monitoring (Prometheus en datasource par défaut).

## Dépendances
- Prometheus (réseau `monitoring_net`).
- Reverse proxy optionnel pour accès externe.

## Ports
- 3000 (HTTP) lié à 127.0.0.1 par défaut.

## Volumes
- Mono-instance : `grafana_data` → `/var/lib/grafana`
- Multi-tenant : `./data/shared/grafana` → `/var/lib/grafana`

## Risques sécurité
- Compte admin par défaut si les variables ne sont pas définies.
- Tableaux de bord exposés publiquement en cas de proxy mal configuré.

## Configuration recommandée
- Renseigner `GRAFANA_ADMIN_USER` et `GRAFANA_ADMIN_PASSWORD` dans `.env`.
- Ajouter un datasource Prometheus via l’UI ou un provisioning dédié (non inclus pour laisser les secrets hors repo).
- Limiter l’accès à 127.0.0.1 ou passer par un reverse proxy avec authentification.
- Activer les backups/export JSON des dashboards importants.

## Vérification rapide
```
docker compose -f compose/stack.yml ps grafana
curl -I http://127.0.0.1:${GRAFANA_PORT:-3000}/login
```
