# Strudel

## Rôle
Environnement musical/génératif (front web) pour expérimentations audio.

## Dépendances
- Aucun service interne ; utilise `maximus_net` + `ingress_net` pour isoler le trafic.

## Ports
- 7000 (HTTP) lié à 127.0.0.1 dans la stack par défaut ; 8080 dans la variante multi-tenant (`STRUDL_HTTP_PORT`).

## Volumes
- Mono-instance : aucun volume (stateless).
- Multi-tenant : `./data/shared/strudel` → `/workspace` pour stocker vos projets.

## Risques sécurité
- Interface sans authentification native.
- Ressources statiques pouvant être modifiées si volume en écriture partagé.

## Configuration recommandée
- Laisser l’accès en local ou protéger via le reverse proxy (auth, HTTPS).
- Pour un usage multi-utilisateur, séparer les volumes par tenant et limiter les droits d’écriture.

## Vérification rapide
```
docker compose -f compose/stack.yml ps strudel
curl -I http://127.0.0.1:${STRUDEL_PORT:-7000}/
```
