# AI Proxy

## Rôle
Serveur HTTP statique placeholder (nginx ou python simple serveur) pour servir des assets IA ou pages statiques.

## Dépendances
- Aucun service interne ; réseaux `koff_net` + `ingress_net`.

## Ports
- 8081 (HTTP) lié à 127.0.0.1.

## Volumes
- Mono-instance : `./data/shared/ai-proxy` → `/usr/share/nginx/html:ro`
- Multi-tenant : même volume partagé (statique).

## Risques sécurité
- Aucun contrôle d’accès intégré ; fichiers servis en clair.
- Si volume modifiable, risque de dépôt de contenu malveillant.

## Configuration recommandée
- Conserver `read_only: true` (déjà activé) pour la racine web.
- Placer un reverse proxy si exposition externe (TLS, auth basique).
- Versionner uniquement des fichiers publics ; garder les assets sensibles hors repo.

## Vérification rapide
```
docker compose -f compose/stack.yml ps ai-proxy
curl -I http://127.0.0.1:${AI_PROXY_PORT:-8081}/
```
