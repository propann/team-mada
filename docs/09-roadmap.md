# 09 — Roadmap

## Court terme
- Ajouter des règles de scrape Prometheus pour n8n, Mosquitto et Qdrant (si endpoints disponibles).
- Publier des dashboards Grafana de base (synthèse CPU/RAM/volumes, santé n8n/MQTT).
- Script de backup MinIO/Qdrant (snapshot volumes ou `mc mirror`).

## Moyen terme
- Intégrer un proxy d'identité (OAuth2-Proxy/Authelia) en option pour protéger n8n/Grafana.
- Ajouter un service d'embeddings GPU/CPU dédié (ex : text-embedding, Sentence Transformers) avec build optionnel.
- Automatiser la génération des certificats MQTT (Let's Encrypt ACME DNS ou CA interne).

## Long terme / idées
- Fournir des playbooks Ansible pour déploiement sur VPS bare-metal.
- Ajouter des tests automatisés (scans Compose, linters YAML, gitleaks en local).
- Support Kubernetes (Helm chart) pour équipes nécessitant du scaling.
- Ajouter un mode HA pour Postgres/Redis si la charge le demande.
