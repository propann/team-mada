# JEUX-TEXT

Jeu web minimaliste en mode terminal, ambiance console/zombie. Il charge des scènes JSON et sauvegarde la progression dans `localStorage`.

## Rôle
- Proposer un mini récit textuel accessible via le site principal (`/jeux-text/`).
- Fonctionne sans backend lourd : Node.js sert les assets statiques et expose un endpoint santé.

## Accès
- URL : `/jeux-text/`
- Healthcheck : `/jeux-text/health` (retourne `{ "ok": true }`).

## Commandes disponibles
- `help` : afficher la liste des commandes.
- `start` : initialiser/recommencer la partie (charge la scène `intro`).
- `look` : ré-afficher la description de la scène courante.
- `go <scene>` : se déplacer vers une scène accessible (ex. `go couloir`).
- `inventory` : afficher les objets collectés automatiquement lors des découvertes.
- `clear` : nettoyer l'écran du terminal.

## Modifier les scènes
1. Éditer `apps/jeux-text/scenes.json`.
2. Chaque scène comprend :
   - `title` : nom affiché.
   - `description` : texte de narration.
   - `options` : tableau d'objets `{ "target": "id-scene", "label": "go target - description" }`.
   - `items` : tableau d'objets automatiquement ajoutés à l'inventaire lors de la première visite.
3. Rebuild le service si besoin : `docker compose -f compose/stack.yml build jeux-text`.

## Déploiement Docker
- Service : `jeux-text` (réseau interne `ingress_net`, exposé via le reverse proxy sur `/jeux-text/`).
- Healthcheck interne : `http://jeux-text:8080/health`.

## Notes
- Sauvegarde client : l'état (scène courante, inventaire, scènes visitées) est stocké dans le navigateur.
- Assets front statiques : `apps/jeux-text/{index.html, app.js, style.css, scenes.json}`.
