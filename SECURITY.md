# Sécurité opérationnelle – Team Mada

## Principes généraux
- Aucun secret n'est versionné. Les valeurs sensibles doivent vivre dans un gestionnaire de secrets, dans les variables CI ou dans un fichier `.env` local non commité (voir `.gitignore`).
- Les services admins (n8n, Grafana, Prometheus, MinIO console, PostgreSQL, Mosquitto, Qdrant) ne sont jamais exposés publiquement ; utiliser un VPN ou un proxy d'authentification (Cloudflare Access / Authelia / OAuth2-Proxy) si un accès HTTP est requis.
- Ports autorisés côté Internet : **80/443 uniquement** et uniquement pour le reverse proxy. Les autres ports restent bindés sur `127.0.0.1`.

## Gestion et rotation des secrets
1. Renseigner `.env` à partir de `.env.example` en remplaçant toutes les valeurs `CHANGE_ME` / placeholders.
2. Stocker les valeurs définitives dans un secret manager (Vault, AWS SSM, Doppler…) et injecter via CI/CD ou `docker compose --env-file`.
3. Rotation :
   - Générer une nouvelle valeur (mot de passe fort / clé API) et l'injecter.
   - Redéployer les services dépendants.
   - Révoquer l'ancien secret côté fournisseur (MinIO, PostgreSQL, Grafana, Groq…)
4. Si un secret a pu fuiter :
   - Le révoquer immédiatement.
   - Changer toutes les occurrences liées (ex : DB user + password, tokens API).
   - Purger l'historique Git si le secret a été commité : `git filter-repo --path <fichier> --invert-paths` ou BFG Repo-Cleaner, puis régénérer les clés compromises.

## Fichiers sensibles à ignorer
- `.env`, `secrets/`, certificats (`*.pem`, `*.key`, `*.pfx`, `*.kubeconfig`), dumps (`backups/`, `*.sql*`), artefacts de scans (`*.sarif`, `gitleaks-report.json`).
- Ajouter tout nouveau fichier contenant des secrets dans `.gitignore` dès sa création.

## Docker / Compose
- `restart: unless-stopped` et `no-new-privileges` appliqués partout ; `cap_drop: ["ALL"]` généralisé (avec `NET_BIND_SERVICE` rajouté uniquement pour Caddy).
- Limites de ressources définies (pids/mémoire) pour éviter les débordements et DoS locaux.
- Volumes en lecture seule pour les services statiques (`ai-proxy`, `embed-service`) ; réseaux internes séparés (`monitoring_net`, `azoth_net`, `koff_net`, etc.).
- Aucun service applicatif n'est publié en `0.0.0.0` hors reverse proxy.

## Reverse proxy
- Caddy force la redirection HTTP→HTTPS, émet des certificats ACME, applique des en-têtes de sécurité (HSTS, CSP restrictive, X-Frame-Options DENY, Referrer-Policy no-referrer, Permissions-Policy minimaliste, X-Content-Type-Options nosniff).
- Blocage des chemins sensibles (`/.git`, `/admin`, `/metrics`, `/backup`, etc.), limite de taille de requête (20 MB) et rate-limit IP sur le proxy n8n.
- Prévoir un mécanisme d'authentification applicative (n8n basic auth activé via env) et, pour l'admin, un proxy d'identité ou un VPN.

## Accès SSH et pare-feu
- SSH : interdiction du login root, authentification par clé uniquement, `PasswordAuthentication no`, `PermitRootLogin no`, journalisation et fail2ban recommandés.
- Pare-feu (UFW) : autoriser `22/tcp` depuis IP admin/VPN uniquement, `80/443` si reverse proxy actif ; tout le reste doit être bloqué. Ajouter des règles egress si nécessaire.

## Observabilité sans fuite
- Les endpoints `/metrics`, consoles Grafana/Prometheus et la console MinIO doivent rester privés (tunnel SSH ou VPN). Ne pas exposer d'adresses internes ou de tokens dans les dashboards.
- Vérifier que les logs ne contiennent pas de secrets avant export / partage.

## CI et contrôles
- CI (voir `.github/workflows/security.yml`) : scan de secrets via Gitleaks, `npm audit` (dépendances `ai-proxy`), vérification qu'aucun `.env` n'est suivi.
- Exécuter `scripts/security-audit.sh` sur une stack démarrée pour vérifier ports exposés, capabilités et volumes read-only.

## Liste des ports autorisés
- Public : `80` / `443` (reverse proxy Caddy uniquement).
- Privé/local (loopback uniquement) : `5678/5679` (n8n), `3000` (Grafana), `9090` (Prometheus), `1883/8883` (MQTT), `9000/9001` (MinIO), `6333` (Qdrant), `7000` (Strudel), `8081` (ai-proxy), `8082` (embed-service), ports Postgres/Redis internes.
