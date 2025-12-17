# AI Proxy

## Rôle
Passerelle HTTP destinée à router les requêtes vers des services IA internes ou futurs (placeholder sûr par défaut).

## Dépendances
- Réseaux `koff_net` et `ingress_net`.

## Ports
- 8081 (HTTP) – bind 127.0.0.1 par défaut.

## Volumes
- Aucun par défaut.

## Risques sécurité
- Placeholder servant un simple serveur HTTP : ajouter authentification/tokens avant de brancher un modèle réel.
- Ne pas exposer publiquement sans filtrage.

## Configuration recommandée
- Remplacer l'image par votre proxy IA (par ex. FastAPI) et ajouter des ACL par tenant.
- Mettre en place du rate limiting via le reverse proxy.

## Vérification rapide
```
curl -fsS http://127.0.0.1:${AI_PROXY_PORT:-8081}/
```
