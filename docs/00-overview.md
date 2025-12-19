# 00 — Vue d'ensemble

## Vision
Construire une stack Docker sobre mais complète pour automatiser, monitorer et expérimenter des briques IA/temps réel sans exposer de secrets. Chaque service est épinglé, cloisonné par réseau et prêt à être remplacé ou étendu.

## Principes
- 🔒 **Sécurité par défaut** : ports liés à 127.0.0.1, `cap_drop: [ALL]`, `no-new-privileges` et utilisateurs non-root.
- ⚙️ **Composabilité** : un fichier Compose principal, une variante multi-tenant, un reverse proxy optionnel.
- 🚀 **Prêt à l'emploi** : scripts de bootstrap/backup/restore/healthcheck fournis.
- 📦 **Sanitisation** : aucune donnée sensible versionnée ; placeholders `YOUR_DOMAIN`, `YOUR_TOKEN`, `YOUR_SECRET`.

## Modules inclus
- Automatisation : n8n + Postgres + Redis.
- Messaging : Mosquitto (MQTT) avec ACL/TLS optionnels.
- Observabilité : Prometheus + Grafana.
- Stockage : MinIO.
- Vecteurs : Qdrant + service HTTP pour embeddings.
- Web internes : ai-proxy statique (appel Groq), Strudel, jeux-text.

## Quand l'utiliser ?
- Lab interne ou POC nécessitant workflows, MQTT et monitoring.
- Déploiement auto-hébergé derrière VPN / tunnel SSH.
- Base technique pour ajouter des workers IA ou des APIs métier.

## Ce que la stack n'inclut pas
- Pas de CI/CD fournie pour la mise en prod.
- Pas d'autoscaling ni d'orchestrateur Kubernetes.
- Pas d'authentification centralisée (à ajouter via proxy d'identité si besoin).
