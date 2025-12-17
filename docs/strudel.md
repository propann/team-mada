# Strudel

## Rôle
Serveur de musique générative JavaScript pour expérimenter et diffuser des patterns audio.

## Dépendances
- Réseau `maximus_net` et `ingress_net`.

## Ports
- 7000 (HTTP) – bind 127.0.0.1 par défaut.

## Volumes
- Pas de volume défini par défaut (stateless). Ajouter un montage si vous stockez des presets/scripts.

## Risques sécurité
- Pas d'authentification native : placer derrière un reverse proxy avec auth si exposé.
- Charger du code JS externe peut exécuter du code arbitraire côté serveur.

## Configuration recommandée
- Ajouter un pare-feu applicatif ou basic auth via reverse proxy.
- Monter un volume pour gérer les compositions versionnées.

## Vérification rapide
```
curl -fsS http://127.0.0.1:${STRUDEL_PORT:-7000}/
```
