# Embed Service

## Rôle
Point de terminaison pour générer ou servir des embeddings (placeholder HTTP minimal prêt à être remplacé par un service réel).

## Dépendances
- Réseaux `koff_net` et `ingress_net`.

## Ports
- 8082 (HTTP) – bind 127.0.0.1 par défaut.

## Volumes
- Aucun par défaut.

## Risques sécurité
- Pas d'authentification ni de limitation de charge dans la version placeholder.
- Embeddings peuvent contenir des données sensibles si vous les générez à partir de contenu privé.

## Configuration recommandée
- Remplacer par votre implémentation (FastAPI/Go) avec auth et quotas.
- Restreindre l'accès au réseau interne ou via reverse proxy authentifié.

## Vérification rapide
```
curl -fsS http://127.0.0.1:${EMBED_SERVICE_PORT:-8082}/
```
