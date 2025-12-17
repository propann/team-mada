# Az Stack – Déploiement multi-tenant clef en main

Bienvenue dans la reproduction nettoyée d’un export Docker (« az-stack-export.tar.gz »). Le dépôt fournit tout ce qu’il faut pour relancer la stack sur un Debian récent avec Docker Compose, sans données sensibles et avec une bonne dose de documentation.

## 🎯 Objectifs
- Offrir un **bundle Docker multi-tenant** (azoth, maximus, koff) couvrant automatisation (n8n), bases de données (PostgreSQL), cache/queue (Redis), vecteurs (Qdrant), stockage objet (MinIO), observabilité (Grafana/Prometheus), MQTT, Strudel, AI Proxy et service d’embed minimal.
- Rester **reproductible** et **documenté** : `.env.example`, scripts utilitaires et guides pratiques.
- Assurer que tout tourne en local via `docker compose` sur Debian, avec des ports bindés sur `127.0.0.1` et un guide optionnel de reverse-proxy.

## 🧱 Architecture
```
Client → (Reverse-proxy optionnel) → 127.0.0.1:PORTS
                                    ├─ n8n-{tenant}        (5678)
                                    ├─ postgres-{tenant}   (5432 internal)
                                    ├─ redis-{tenant}      (6379 internal)
                                    ├─ qdrant-{tenant}     (6333)
                                    ├─ minio-{tenant}      (9000/9001)
                                    ├─ mqtt                (1883)
                                    ├─ grafana             (3000)
                                    ├─ prometheus          (9090)
                                    ├─ strudel             (8080)
                                    ├─ ai-proxy            (8081)
                                    └─ embed-service       (8082)
```
- **Isolation par tenant** : chaque locataire dispose de son trio PostgreSQL/Redis/n8n, d’instances Qdrant et MinIO séparées avec des volumes dédiés.
- **Réseau interne unique** : les services exposent seulement ce qui est nécessaire en `127.0.0.1`. Exposez vers l’extérieur via reverse-proxy (cf. section dédiée) pour ajouter TLS/ACL.
- **Extensions** : Grafana/Prometheus collectent les métriques locales, MQTT sert de bus léger, Strudel reste l’aire de jeu musicale.

### Services et ports
| Service | Ports (hôte) | Notes |
| --- | --- | --- |
| n8n-{tenant} | 127.0.0.1:56{tenant_idx}8 (ex. azoth → 5608) | Basic auth activable via `.env` |
| postgres-{tenant} | 127.0.0.1:54{tenant_idx}2 | Utilisé uniquement en interne par défaut |
| redis-{tenant} | interne | Protégé par mot de passe |
| qdrant-{tenant} | 127.0.0.1:63{tenant_idx}3 | API key via `.env` |
| minio-{tenant} (API/console) | 127.0.0.1:90{tenant_idx}0 / 90{tenant_idx}1 | Un bucket par tenant conseillé |
| mqtt | 127.0.0.1:${MQTT_PORT:-1883} | Mosquitto |
| grafana | 127.0.0.1:${GRAFANA_PORT:-3000} | Admin par défaut `admin/admin` à changer |
| prometheus | 127.0.0.1:${PROMETHEUS_PORT:-9090} | Scrape des endpoints internes |
| strudel | 127.0.0.1:${STRUDL_HTTP_PORT:-8080} | Serveur JS génératif |
| ai-proxy | 127.0.0.1:${AI_PROXY_PORT:-8081} | Proxy HTTP basique (Nginx) |
| embed-service | 127.0.0.1:${EMBED_SERVICE_PORT:-8082} | API d’embedding minimaliste |

*(tenant_idx = 1 pour azoth, 2 pour maximus, 3 pour koff)*

### Conventions de nommage
- Services : `<service>-<tenant>` (sauf services partagés comme mqtt/grafana/prometheus/ai-proxy/embed-service).
- Volumes : `<compose_project>_<service>-<tenant>_data` pour faciliter les sauvegardes.
- Réseau Docker : `${COMPOSE_PROJECT_NAME}_internal`.
- Dossiers hôte : `data/<tenant>/<service>`.

## 🚀 Installation pas à pas (Debian)
1. **Prérequis** : Docker + Docker Compose v2 installés, port 80/443 libres si reverse-proxy.
2. **Cloner** : `git clone <ce dépôt>` puis `cp .env.example .env` et éditez les mots de passe.
3. **Préparer les dossiers** : `bash scripts/bootstrap.sh` (crée `data/` et `backups/`, règle les permissions).
4. **Lancer** : `docker compose up -d` (utilise `docker-compose.yml`).
5. **Vérifier** : `bash scripts/healthcheck.sh` pour s’assurer que les endpoints répondent.

## 🔁 Mise à jour & rollback
- **Update images** : `docker compose pull && docker compose up -d`.
- **Consigner la version** : `docker compose images > backups/compose-images-$(date +%F).txt`.
- **Rollback rapide** : `docker compose down && docker compose -f _rendered.compose.yml up -d` (utilise le fichier rendu enregistré avant la mise à jour).
- **Astuce** : Gardez une copie datée de `_rendered.compose.yml` après chaque déploiement stable.

## 💾 Backup / Restore
### Sauvegarde
- PostgreSQL : `bash scripts/backup.sh postgres` → dumps compressés par tenant dans `backups/postgres/`.
- Volumes MinIO/Qdrant/n8n : `bash scripts/backup.sh volumes` → archive tar.gz par tenant.
- Fichier de composition : `cp docker-compose.yml _rendered.compose.yml` pour figer l’état.

### Restauration
- `bash scripts/restore.sh postgres <dumpfile>` pour restaurer un tenant précis.
- `bash scripts/restore.sh volumes <archive.tar.gz>` pour remettre les volumes (arrête les services ciblés avant extraction).

## 🔧 Troubleshooting
- **Ports déjà utilisés** : ajustez les bindings dans `.env` ou via override compose.
- **Services en boucle de restart** : `docker compose logs <service>` puis vérifiez les variables obligatoires.
- **Droits fichier** : relancez `scripts/bootstrap.sh` (il applique `chmod 750` sur `data` et `backups`).
- **n8n inaccessible** : vérifier `N8N_BASIC_AUTH_*` et l’URL `N8N_WEBHOOK_URL` (doit correspondre au reverse-proxy si activé).
- **MinIO 403** : assurez-vous que les credentials sont identiques côté client et dans `.env` ; créez un bucket par tenant.

## 🔐 Guide reverse-proxy (optionnel)
- Positionnez un **Traefik** ou **Caddy** devant les ports exposés.
- Limitez l’écoute à `127.0.0.1` côté services (déjà le cas) et publiez uniquement les hostnames voulus.
- Activez **HTTPS** (Let’s Encrypt) et, si possible, un **SSO** (OIDC) pour Grafana/n8n.
- Exemple Traefik minimal : points d’entrée `websecure`, middlewares `basicAuth` pour n8n, `rateLimit` pour l’AI proxy.

## 📦 Arborescence
```
.
├─ docker-compose.yml
├─ _rendered.compose.yml
├─ .env.example
├─ scripts/
│  ├─ bootstrap.sh
│  ├─ backup.sh
│  ├─ restore.sh
│  └─ healthcheck.sh
└─ docs/
   ├─ n8n.md
   ├─ mqtt.md
   ├─ grafana.md
   ├─ prometheus.md
   ├─ qdrant.md
   ├─ minio.md
   ├─ strudel.md
   ├─ ai-proxy.md
   └─ embed-service.md
```

Bon déploiement !
