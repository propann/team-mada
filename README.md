# 🌐 Plateforme Docker modulaire (Debian) – n8n, monitoring, IA, MQTT, Strudel

Dépôt de référence **sanitisé** pour déployer une stack modulaire sur VPS Debian. Aucun secret n'est versionné ; toutes les valeurs sensibles se configurent via `.env` (copie de `.env.example`).

## 📁 Arborescence
```
compose/                 # Fichiers Docker Compose (stack & options reverse-proxy)
configs/                 # Configs montées en read-only (MQTT, reverse proxy, Prometheus, Postgres init)
docs/                    # Fiches service par service
scripts/                 # Utilitaires (bootstrap, backup, restore, audit)
backups/                 # Emplacement local des sauvegardes (git-ignoré)
logs/                    # Journaux applicatifs (git-ignoré)
.env.example             # Variables à renseigner avant déploiement
.gitignore               # Ignore secrets/logs/dumps
```

## 🏗️ Architecture globale
Services principaux (tous optionnels sauf DB/cache pour n8n) :
- **n8n** (automatisation) – réseaux `backbone_net`, `azoth_net`
- **PostgreSQL** (DB) – réseaux `backbone_net`, `azoth_net`
- **Redis** (cache) – réseau `backbone_net`
- **Mosquitto** (MQTT) – réseau `backbone_net`
- **Grafana + Prometheus** (monitoring) – réseau `monitoring_net`
- **MinIO** (S3) – réseau `backbone_net`
- **Qdrant** (vecteurs) – réseaux `backbone_net`, `koff_net`
- **Strudel** (musique générative) – réseaux `maximus_net`, `ingress_net`
- **AI proxy** (placeholder HTTP) – réseaux `koff_net`, `ingress_net`
- **Embed service** (placeholder HTTP) – réseaux `koff_net`, `ingress_net`
- **Reverse proxy Caddy** (optionnel) – réseau `ingress_net`

### Diagramme ASCII
```
                     [ Internet ]
                          |
                   (optionnel Caddy)
                          |
                      ingress_net
                    /     |      \
               strudel  ai-proxy  embed-service
                   |         \        /
                maximus_net   koff_net
                          \    /
                       backbone_net
      azoth_net ---- n8n ---- postgres
            \          \       /
             \          redis  /
              \         mosquitto
               \             |
                \         minio
                 \        /
                 monitoring_net
                /             \
         prometheus        grafana
```

## 🚀 Installation rapide (Debian + Docker Compose)
1. **Prérequis** : Docker Engine + Docker Compose v2 installés, ports 80/443 libres si reverse proxy.
2. **Cloner** : `git clone https://github.com/<TON_USER>/team-mada && cd team-mada`
3. **Bootstrap** : `./scripts/bootstrap.sh` (crée `.env`, dossiers, vérifie les binaires).
4. **Configurer** : éditer `.env` (mots de passe DB, MinIO, ports, domaines éventuels).
5. **Démarrer** : `docker compose -f compose/docker-compose.yml up -d`.
6. **Option Internet** : `ENABLE_REVERSE_PROXY=true` puis `docker compose -f compose/docker-compose.yml -f compose/reverse-proxy.caddy.yml up -d` pour exposer via Caddy/HTTPS.

## ▶️ Utilisation quotidienne
- **Démarrer** : `docker compose -f compose/docker-compose.yml up -d`
- **Arrêter** : `docker compose -f compose/docker-compose.yml down`
- **Logs** : `docker compose -f compose/docker-compose.yml logs -f n8n`
- **Mise à jour** : `docker compose pull && docker compose -f compose/docker-compose.yml up -d`
- **Rollback** : recharger une sauvegarde Postgres via `./scripts/restore.sh <dump.sql.gz>` + relecture des configs versionnées.

## 💾 Sauvegarde & restauration
- **Sauvegarde Postgres** : `./scripts/backup.sh` (dumps compressés dans `backups/postgres/`).
- **Restauration** : `./scripts/restore.sh backups/postgres/<fichier>.sql.gz` (stack démarrée pour réappliquer le dump).
- **Configs** : toute la configuration applicative est versionnée dans `configs/` (sans secrets). Exportez vos dashboards Grafana au format JSON.

## 🔐 Baseline sécurité (par défaut)
- `restart: unless-stopped` sur tous les services.
- Ports bindés sur `127.0.0.1` pour éviter l'exposition Internet accidentelle.
- Réseaux isolés par tenant logique : `azoth`, `maximus`, `koff`, plus `monitoring` et `ingress`.
- `no-new-privileges` + `cap_drop` (là où compatible) ; utilisateurs non-root lorsque possible.
- Bases/queues non publiées (Postgres, Redis, Qdrant) ; MQTT avec ACL et TLS optionnel.
- Reverse proxy optionnel (Caddy) pour ajouter TLS/Let’s Encrypt et basic auth.

### Modes d’exposition
- **LAN only (par défaut)** : garder les ports sur `127.0.0.1`, ne pas lancer le reverse proxy. Accès via SSH tunnel ou VPN.
- **Mode Internet** : activer le reverse proxy, fournir `PUBLIC_DOMAIN` + `EMAIL_LETSENCRYPT`, ajouter authentification sur Grafana/n8n/Strudel, ouvrir uniquement 80/443 dans le firewall.

### Checklist système
- **UFW/iptables** : autoriser `22/tcp`, `80/443` (si proxy), sinon uniquement les ports SSH/VPN. Bloquer `1883/8883` depuis l’extérieur sauf besoin explicite.
- **fail2ban** : activer les jails SSH + nginx/caddy si exposé.
- **SSH hardening** : clés publiques uniquement, `PermitRootLogin no`, `PasswordAuthentication no`, port non standard optionnel.
- **Rotation** : planifier `./scripts/backup.sh` (cron/systemd timer), vérifier l’espace disque des volumes Docker.

### MQTT : ACL & TLS
- Utilisateurs à créer via `mosquitto_passwd` (fichier `configs/mqtt/passwords`).
- ACL par tenant (`configs/mqtt/acl`) pour éviter les fuites cross-tenant.
- Templates TLS (auto-signé) décrits dans `docs/mqtt.md` ; ne jamais committer les clés privées.

## 🛡️ Hardening service par service
Voir `/docs` pour les fiches détaillées : n8n, Postgres, Redis, MQTT, Grafana, Prometheus, Qdrant, MinIO, Strudel, AI Proxy, Embed Service.

## 🔍 Troubleshooting
- **Containers ne démarrent pas** : `docker compose -f compose/docker-compose.yml logs --tail 50 <service>`.
- **Port déjà utilisé** : ajuster les valeurs dans `.env` (ex: `N8N_PORT=5680`).
- **TLS MQTT** : vérifier la présence des certs dans `configs/mqtt/certs/` et les permissions (lectures). 
- **Reverse proxy** : recharger Caddy `docker compose -f compose/reverse-proxy.caddy.yml exec caddy caddy reload --config /etc/caddy/Caddyfile`.
- **Audit rapide** : `./scripts/security-audit.sh` (ports exposés, cap_drop, variables sensibles restantes).

## 🧭 Ressources complémentaires
- Templates de configurations supplémentaires dans `configs/`.
- Fiches service dans `docs/` avec risques, ports et checks rapides.

