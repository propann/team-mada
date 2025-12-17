# Grafana

## Rôle
Visualisation des métriques (Prometheus) et autres sources.

## Dépendances
- Prometheus pour les métriques système.
- Réseau `monitoring_net`.

## Ports
- 3000 (HTTP) – bind 127.0.0.1 par défaut.

## Volumes
- `grafana_data` → `/var/lib/grafana`

## Risques sécurité
- Comptes admin par défaut : changer rapidement le mot de passe.
- Plugins tiers peuvent exfiltrer des données.

## Configuration recommandée
- Mettre à jour `GF_SECURITY_ADMIN_PASSWORD` via `.env` ou variables locales.
- Activer l'authentification par proxy si exposé via reverse proxy.
- Sauvegarder les dashboards exportés (JSON) plutôt que la base interne.

## Vérification rapide
```
curl -fsS http://127.0.0.1:${GRAFANA_PORT:-3000}/api/health
```
