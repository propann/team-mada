# 08 — Sécurité

## Principes de base
- 🔐 Aucun secret dans Git : utiliser `.env` local + secret manager.
- 🌐 Ports publics fermés par défaut : n'ouvrir que 80/443 si reverse proxy, sinon VPN/tunnel.
- 👤 Utilisateurs non-root et `cap_drop: [ALL]` appliqués ; conserver cette posture pour tout nouveau service.

## Bonnes pratiques
- Générer des mots de passe forts pour Postgres, Redis, MinIO, Grafana, n8n, Qdrant.
- Activer TLS pour MQTT si des clients sortent du LAN/VPN (certificats dans `configs/mqtt/certs/`).
- Régénérer les clés `N8N_ENCRYPTION_KEY` et `GROQ_API_KEY` en cas de doute, puis redeployer.
- Ajouter un pare-feu (UFW ou équivalent) : autoriser SSH (port custom) + 80/443 si proxy, bloquer le reste.
- Sur le reverse proxy : forcer HTTPS, ajouter rate-limit et authentification (Caddy peut intégrer basique/OAuth2-Proxy en amont).
- Nettoyer les logs avant partage : pas d'URL internes, pas de tokens.

## Erreurs à éviter
- Laisser `ENABLE_REVERSE_PROXY=true` sans renseigner `PUBLIC_DOMAIN=YOUR_DOMAIN` et `EMAIL_LETSENCRYPT`.
- Exposer directement les ports MQTT/MinIO/Postgres sur Internet.
- Oublier de remplir `.env` (valeurs `CHANGE_ME`).
- Committer des mots de passe ou clés dans les dashboards Grafana ou workflows n8n.

## Détection et audit
- Lancer `./scripts/security-audit.sh` (vérifie ports exposés, capabilités, volumes read-only) sur la stack active.
- Utiliser `docker compose -f compose/stack.yml config` pour inspecter les options effectives avant déploiement.
- Surveiller les dépendances JS de `ai-proxy` via `npm audit` si vous modifiez son code.

## Révocation / incident
1. Révoquer immédiatement le secret exposé (DB, Groq, MinIO...).
2. Remplacer la valeur dans `.env` et redémarrer les services concernés.
3. Purger l'historique Git si un secret a été commit par erreur.
4. Analyser les logs d'accès (reverse proxy, mosquitto, n8n) pour détecter un usage abusif.
