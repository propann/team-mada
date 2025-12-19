# Audit documentaire et opérationnel

## Objectif réel du projet
Plateforme Docker Compose prête à déployer pour assembler un socle d'automatisation (n8n), de messagerie temps réel (MQTT), d'observabilité (Prometheus/Grafana), de stockage objet (MinIO) et de moteurs IA/embeddings (Qdrant, services HTTP légers). La stack vise une utilisation auto-hébergée, cloisonnée par réseaux Docker, avec option multi-tenant.

## À quoi il sert concrètement
- Automatiser des workflows via n8n connectés à Postgres/Redis.
- Faire transiter des événements IoT/temps réel via Mosquitto avec ACL.
- Stocker objets et artefacts techniques dans MinIO.
- Indexer/requêter des embeddings via Qdrant et un service HTTP d'embeddings.
- Servir une page statique (ai-proxy) et un mini-jeu web (jeux-text/Strudel).
- Surveiller l'état de la stack via Prometheus + Grafana.

## Fonctionnement global (vue synthétique)
- Compose principal : `compose/stack.yml` (réseaux `backbone_net`, `ingress_net`, `monitoring_net` + réseaux par tenant).
- Variante multi-tenant : duplication des services n8n/Postgres/Redis/MQTT par environnement (`azoth`, `maximus`, `koff`).
- Reverse proxy optionnel Caddy (fichier `compose/reverse-proxy.caddy.yml`) pour HTTPS public sur `YOUR_DOMAIN`.
- Scripts d'exploitation :
  - `scripts/bootstrap.sh` : prépare les dossiers et copie `.env.example` vers `.env`.
  - `scripts/backup.sh` / `scripts/restore.sh` : dump et restauration Postgres.
  - `scripts/healthcheck.sh` / `scripts/security-audit.sh` : vérifications basiques (ports, capabilités, volumes).
- Services applicatifs : n8n (automatisation), mosquitto (MQTT), Postgres/Redis (persistance), MinIO, Qdrant, Grafana/Prometheus, ai-proxy (HTTP simple vers Groq), embed-service (serveur HTTP statique), jeux-text (jeu web), Strudel (audio/visuel génératif).

## Ce qui manque aujourd'hui
- Guide de démarrage rapide consolidé (documentation éclatée dans plusieurs fichiers).
- Vue architecture claire (diagramme + flux réseau/data).
- Procédure d'installation reproductible de bout en bout.
- Section dédiée aux bonnes pratiques sécurité (TLS MQTT, reverse proxy, secrets GROQ_API_KEY).
- Roadmap des évolutions prévues.

## Points sensibles / à nettoyer
- Les exemples de domaines dans `.env.example` doivent être remplacés par `YOUR_DOMAIN` et ne jamais être déployés tels quels.
- L'API key Groq (`GROQ_API_KEY`) ne doit jamais être commitée : l'injecter via `.env` ou secret manager.
- Vérifier avant déploiement que seuls 80/443 (proxy) ou les ports loopback nécessaires sont ouverts.
- S'assurer que les volumes `configs/mqtt/passwords` et `configs/mqtt/certs` restent hors Git et correctement permissions.
- Aucun secret n'est versionné à ce stade ; conserver cette discipline lors des ajouts de services ou de pipelines CI.
