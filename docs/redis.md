# Redis

## Rôle
Cache en mémoire et file d'attente légère pour n8n.

## Dépendances
- Volume `redis_data` pour la persistance AOF.
- Réseau `backbone_net`.

## Ports
- Aucun port publié (service interne uniquement).

## Volumes
- `redis_data` → `/data`

## Risques sécurité
- Mot de passe vide par défaut : définir un secret fort via `requirepass` si vous ouvrez à d'autres services.
- Ne pas exposer Redis sur Internet (pas de TLS intégré ici).

## Configuration recommandée
- Garder le service interne. Si besoin, ajouter `masterauth` + TLS via image dédiée.
- Ajuster `save`/`appendonly` selon la criticité des données.

## Vérification rapide
```
docker compose exec redis redis-cli ping
```
