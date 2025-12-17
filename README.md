# Plateforme Docker modulaire (Debian) – n8n, monitoring, MQTT, IA, Strudel

Dépôt **sanitisé** pour déployer une stack Docker Compose multi-tenant (azoth / maximus / koff) sur Debian. Aucune donnée sensible n'est versionnée : la configuration passe uniquement par `.env` (copié depuis `.env.example`).

## Arborescence
```
compose/                 # Fichiers Compose (stack durcie, variante multi-tenant, reverse-proxy)
configs/                 # Configs montées en read-only (MQTT, reverse proxy, Prometheus…)
docs/                    # Fiches service par service + procédures
scripts/                 # Utilitaires (bootstrap, backup, restore, audit, healthcheck)
backups/                 # Dumps Postgres (git-ignoré)
logs/                    # Journaux applicatifs (git-ignoré)
.env.example             # Variables à renseigner (valeurs vides / placeholders)
.gitignore               # Ignore secrets/logs/dumps/artefacts
```

## Architecture globale
- **Stack par défaut** : `compose/stack.yml` (réseaux isolés par domaine fonctionnel, ports liés à 127.0.0.1).
- **Variante multi-tenant** : `compose/multi-tenant.yml` (services dupliqués azoth / maximus / koff + services partagés).
- **Reverse proxy optionnel** : `compose/reverse-proxy.caddy.yml` pour exposer via HTTPS sans secrets versionnés.

### Diagramme ASCII (stack par défaut)
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

## Installation pas à pas (Debian + Docker Compose)
1. **Prérequis** : Docker Engine + Compose v2 installés, ports 80/443 libres si reverse proxy.
2. **Cloner** : `git clone https://github.com/<TON_USER>/team-mada && cd team-mada`.
3. **Bootstrap** : `./scripts/bootstrap.sh` (vérifie Docker, crée `.env`, dossiers backups/logs/certs).
4. **Configurer** : éditer `.env` (utilisateurs DB, mots de passe, clés n8n, MinIO, ports). Valeurs vides par défaut.
5. **Choisir la stack** :
   - mono-instance durcie : `docker compose -f compose/stack.yml up -d`
   - multi-tenant : `docker compose -f compose/multi-tenant.yml up -d`
6. **Option internet** : ajouter `-f compose/reverse-proxy.caddy.yml` et renseigner `PUBLIC_DOMAIN` + `EMAIL_LETSENCRYPT`.

## Démarrage / arrêt / cycle de vie
- **Démarrer** : `docker compose -f compose/stack.yml up -d` (ou `multi-tenant.yml`).
- **Arrêter** : `docker compose -f <stack> down`.
- **Logs** : `docker compose -f <stack> logs -f <service>`.
- **Mise à jour images** : `docker compose -f <stack> pull && docker compose -f <stack> up -d`.
- **Rollback** : restaurer le dump Postgres (ci-dessous) + recharger les configs versionnées.

## Sauvegarde & restauration
- **Sauvegarde Postgres** : `./scripts/backup.sh` (dump compressé dans `backups/postgres/`).
- **Restauration** : `./scripts/restore.sh backups/postgres/<fichier>.sql.gz` (stack démarrée, variables DB cohérentes avec le dump).
- **Exports applicatifs** :
  - Grafana : exporter les dashboards JSON (ne pas stocker les datasources sensibles).
  - n8n : exporter les workflows critiques.

## Baseline sécurité (par défaut)
- `restart: unless-stopped` partout, ports liés sur `127.0.0.1` pour éviter l'exposition involontaire.
- Utilisateurs non-root quand possible (`postgres`, `redis`, `mosquitto`, `grafana`, `n8n`), `no-new-privileges` et `cap_drop` activés sur les services sensibles.
- FS durci : `read_only` pour les services statiques, `tmpfs /tmp` pour n8n.
- Réseaux séparés (`backbone_net`, `monitoring_net` interne, `ingress_net`, réseaux par tenant dans la variante multi-tenant).
- Postgres/Redis/Qdrant non publiés sur Internet ; MQTT avec ACL + TLS optionnel ; reverse proxy désactivé par défaut.

### Mode LAN only vs Internet
- **LAN only (par défaut)** : aucune ouverture publique, accès via SSH tunnel/VPN, pas de reverse proxy.
- **Mode Internet** : activer le reverse proxy, ouvrir uniquement 80/443, forcer HTTPS, ajouter authentification forte (Grafana admin, basic auth n8n déjà activée), envisager un WAF/rate-limit.

### Durcissement système recommandé
- **Pare-feu** : autoriser `22/tcp` (ou port SSH custom) et `80/443` si proxy. Bloquer `1883/8883/9000/9001` depuis Internet.
- **SSH** : clés seules, `PermitRootLogin no`, `PasswordAuthentication no`, bannissement via fail2ban.
- **fail2ban** : jails SSH et reverse proxy.
- **Rotation & sauvegardes** : cron/systemd timer pour `backup.sh`, vérification espace disque volumes Docker, rotation des logs applicatifs.

### MQTT : ACL, utilisateurs, TLS
- ACL d’exemple dans `configs/mqtt/acl` (segmentation par tenant). Personnaliser par sujet.
- Utilisateurs placeholder dans `configs/mqtt/passwords` ; créer avec `docker compose exec <stack> mosquitto mosquitto_passwd -b /mosquitto/config/passwords <user> <motdepasse>`.
- TLS optionnel : déposer `ca.crt`, `server.crt`, `server.key` dans `configs/mqtt/certs/` (non versionnés). Génération possible via `openssl` (cf. `docs/mqtt.md`).

## Documentation détaillée
Les fiches `/docs/*.md` couvrent : n8n, postgres, redis, mqtt, grafana, prometheus, qdrant, minio, strudel, ai-proxy, embed-service. Chaque fiche décrit rôle, dépendances, ports, volumes, risques, configuration recommandée et vérification rapide.

## Troubleshooting
- **Containers ne démarrent pas** : `docker compose -f <stack> logs --tail 50 <service>`.
- **Port déjà utilisé** : adapter les valeurs dans `.env` (ex. `N8N_PORT=5680`).
- **TLS MQTT** : vérifier les certificats et permissions dans `configs/mqtt/certs/`.
- **Reverse proxy** : recharger `docker compose -f compose/reverse-proxy.caddy.yml exec caddy caddy reload --config /etc/caddy/Caddyfile`.
- **Audit rapide** : `./scripts/security-audit.sh` (ports exposés, cap_drop, read-only, variables sensibles restantes).

## Checklist Go-live
- [ ] `.env` rempli (mots de passe DB/MinIO, clés n8n, admin Grafana).
- [ ] Pare-feu appliqué (ports SSH + 80/443 uniquement si proxy).
- [ ] Certificats TLS générés et placés (`configs/mqtt/certs`, reverse proxy si besoin).
- [ ] ACL MQTT et mots de passe créés, accès testés.
- [ ] Sauvegarde initiale Postgres effectuée (`./scripts/backup.sh`).
- [ ] Healthcheck OK (`./scripts/healthcheck.sh`).
- [ ] Monitoring accessible (Prometheus/Grafana via tunnel ou proxy).
