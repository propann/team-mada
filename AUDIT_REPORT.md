# Audit sécurité – Team Mada

## Synthèse
- Aucun secret détecté dans le dépôt (scan manuel par mots-clés). `.env.example` enrichi avec placeholders et images versionnées.
- Docker Compose durci : `cap_drop: [ALL]`, limites mémoire/CPU (pids) généralisées, images épinglées, ports liés à `127.0.0.1` hors proxy.
- Reverse proxy Caddy renforcé : redirection HTTPS, en-têtes de sécurité, blocage de chemins sensibles, limite de taille de requête et rate-limit IP.
- CI ajoutée : gitleaks + `npm audit` + contrôle d'absence de `.env` suivis.

## Cartographie services / exposition
| service              | public? | port(s) hôte        | URL / accès                 | auth?                       | risque              | action |
|----------------------|---------|---------------------|-----------------------------|-----------------------------|---------------------|--------|
| Caddy (reverse proxy)| Oui     | 80, 443             | https://${PUBLIC_DOMAIN}    | ACME TLS + headers + rate-limit | Surface Internet    | Garder 80/443 uniquement, protéger via VPN/IdP si admin |
| n8n                  | Non     | 127.0.0.1:5678/5679 | http://localhost:5678       | Basic auth + clé d’encryption | Workflows sensibles | Laisser privé, passer par proxy authentifié |
| PostgreSQL           | Non     | réseau interne      | postgres://postgres:5432    | MDP dans `.env`             | Données / RCE       | Aucun port public, rotation régulière des creds |
| Redis                | Non     | réseau interne      | redis:6379                  | `requirepass` si défini     | Exfiltration cache  | Conserver privé, mot de passe obligatoire |
| Mosquitto            | Non     | 127.0.0.1:1883/8883 | mqtt://localhost            | ACL + passwd + TLS optionnel| Publish non autorisé| Garder loopback, forcer TLS/ACL |
| Grafana              | Non     | 127.0.0.1:3000      | http://localhost:3000       | Admin user/pass             | Fuite métriques     | Accès via tunnel/VPN uniquement |
| Prometheus           | Non     | 127.0.0.1:9090      | http://localhost:9090       | Aucune par défaut           | Exposition métriques| Rester privé, filtrer via proxy si besoin |
| Qdrant               | Non     | 127.0.0.1:6333      | http://localhost:6333       | API key optionnelle         | Fuite vecteurs      | Garder privé, API key obligatoire |
| MinIO (API/console)  | Non     | 127.0.0.1:9000/9001 | http://localhost:9000       | Root user/pass              | Exfiltration objets | Privé + rotation clés, activer TLS interne si possible |
| Strudel              | Non     | 127.0.0.1:7000      | http://localhost:7000       | Aucun                       | Upload arbitraire   | Utiliser via proxy authentifié si exposé |
| ai-proxy             | Non     | 127.0.0.1:8081      | http://localhost:8081       | Clé API côté backend        | Proxy d’API         | Garder privé, clé en secret manager |
| embed-service        | Non     | 127.0.0.1:8082      | http://localhost:8082       | Aucun                       | Service statique    | Privé uniquement |
| Multi-tenant (azoth/maximus/koff) | Non | boucles locales dédiées | ports internes définis dans `compose/multi-tenant.yml` | Env vars | Isolement données | Conserver séparation réseau interne |

## Ports autorisés (source de vérité)
- **Public Internet** : `80/tcp` et `443/tcp` (reverse proxy Caddy uniquement).
- **Interne / loopback** : `5678/5679` (n8n), `3000` (Grafana), `9090` (Prometheus), `1883/8883` (MQTT), `9000/9001` (MinIO), `6333` (Qdrant), `7000` (Strudel), `8081` (ai-proxy), `8082` (embed-service), `5432` (PostgreSQL), `6379` (Redis), ports multi-tenant spécifiques.

## Correctifs appliqués
- Harden Compose (capabilities, limites ressources, images épinglées, ports en loopback) pour toutes les stacks.
- Reverse proxy Caddy durci (HTTPS obligatoire, headers CSP/HSTS, rate-limit, blocage chemins sensibles, limite taille requête).
- `.env.example` complété (toutes variables, placeholders, images pinned) et `.gitignore` renforcé pour secrets/artefacts.
- Nouvelle CI de sécurité (gitleaks, npm audit, contrôle `.env`) et documentation sécurité/ports.

## Points de vigilance / TODO
- Vérifier la compatibilité runtime des `cap_drop: [ALL]` et des limites mémoire sur chaque service lors du prochain déploiement ; ajuster si certains conteneurs nécessitent des capacités spécifiques.
- Mettre en place un VPN / proxy d’authentification devant n8n, Grafana et la console MinIO si un accès Internet est requis.
- Activer fail2ban côté hôte sur SSH / reverse proxy et appliquer la checklist pare-feu (voir SECURITY.md).
- Purger l’historique Git si un secret réel a déjà été commité (BFG / `git filter-repo`).
