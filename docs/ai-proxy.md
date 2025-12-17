# AI Proxy – parapluie HTTP

Proxy HTTP ultra-simple (Nginx) pour rediriger vers vos modèles préférés. Il ne fait pas de magie, mais il protège vos endpoints des accès directs.

## Accès
- `http://127.0.0.1:8081`
- Montez votre propre config Nginx dans `data/shared/ai-proxy/` si vous voulez des routes dynamiques.

## Idées d’usage
- Ajouter une route `/openai` vers l’API officielle (avec rate limit côté reverse-proxy).
- Servir des modèles locaux derrière un firewall.

## Sécurité
- Limitez les IP sources via le reverse-proxy frontal.
- Ajoutez un middleware d’authentification si vous exposez l’API publiquement. Oui, même pour vos potes.
