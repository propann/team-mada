# ⚙️ Stack Docker modulaire (n8n, MQTT, monitoring, IA, stockage)

Plateforme Compose prête à l'emploi pour orchestrer n8n, Mosquitto, Postgres/Redis, MinIO, Qdrant, Prometheus/Grafana, un proxy IA léger et des apps internes (Strudel, mini-jeu web). Conçue pour être déployée sur serveur Debian ou VM, avec option multi-tenant et reverse proxy HTTPS.

## À quoi sert ce projet ?
- Automatiser vos workflows via n8n en s'appuyant sur Postgres/Redis.
- Collecter et router des messages IoT/temps réel via MQTT avec ACL.
- Stocker et exposer des artefacts (objets, médias) via MinIO.
- Indexer/requêter des embeddings dans Qdrant, accompagnés d'un service HTTP simple.
- Superviser la stack avec Prometheus + Grafana.
- Servir des expériences web internes (ai-proxy statique, Strudel, jeux-text).

## Pour qui ?
- Ops/SRE souhaitant un socle autosuffisant pour automatisation + observabilité.
- Développeurs low-code/no-code utilisant n8n avec persistance Postgres.
- Équipes IoT ou data qui veulent un broker MQTT cloisonné.
- Makers qui testent des features IA en local ou derrière un proxy privé.

## Stack technique
- **Orchestration** : Docker Compose v2
- **Automatisation** : n8n
- **Persistance** : Postgres 16, Redis 7
- **Messagerie** : Mosquitto (MQTT)
- **Stockage objet** : MinIO
- **Vecteurs** : Qdrant
- **Observabilité** : Prometheus + Grafana
- **Web/IA** : ai-proxy (HTTP statique + appel Groq), embed-service (HTTP statique), Strudel, jeux-text
- **Reverse proxy optionnel** : Caddy (HTTPS automatique sur `YOUR_DOMAIN`)

## Lancement rapide (10 minutes)
1. Prérequis : Docker Engine + Compose v2 installés sur votre hôte.
2. Cloner :
   ```bash
   git clone https://YOUR_DOMAIN/team-mada.git
   cd team-mada
   ```
3. Préparer l'environnement :
   ```bash
   ./scripts/bootstrap.sh
   ```
   → crée `.env` depuis `.env.example`, initialise `backups/`, `logs/` et dossiers MQTT.
4. Configurer `.env` (remplacer tous les `CHANGE_ME`, `example.com`, tokens) sans commit.
5. Démarrer la stack par défaut :
   ```bash
   docker compose -f compose/stack.yml up -d
   ```
   Variante multi-tenant : `docker compose -f compose/multi-tenant.yml up -d`.
6. Vérifier :
   ```bash
   docker compose -f compose/stack.yml ps
   docker compose -f compose/stack.yml logs --tail 20
   ```

## Documentation
- Vision & concepts : `docs/00-overview.md`
- Démarrage express : `docs/01-quickstart.md`
- Architecture détaillée : `docs/02-architecture.md`
- Services & ports : `docs/03-services.md`
- Installation complète : `docs/04-installation.md`
- Configuration & variables : `docs/05-configuration.md`
- Cas d'usage : `docs/06-usage.md`
- Maintenance : `docs/07-maintenance.md`
- Sécurité : `docs/08-security.md`
- Roadmap : `docs/09-roadmap.md`
- Audit : `docs/AUDIT.md`

## Avertissement sécurité
- Aucun secret n'est versionné. Ne jamais committer `.env`, certificats, dumps ou tokens.
- Remplacer toute valeur d'exemple par vos propres secrets (`YOUR_DOMAIN`, `YOUR_TOKEN`, etc.).
- Exposer publiquement uniquement 80/443 si le reverse proxy est activé ; sinon rester en accès local/VPN.
- Consulter `docs/08-security.md` avant toute mise en ligne.
