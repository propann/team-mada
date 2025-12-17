# Qdrant – gardien des vecteurs

Chaque tenant dispose de son Qdrant, idéal pour stocker embeddings et recherches sémantiques.

## Accès
- azoth : `http://127.0.0.1:6303`
- maximus : `http://127.0.0.1:6323`
- koff : `http://127.0.0.1:6333`
- Clé API : définie dans `.env` (`QDRANT_API_KEY`).

## Bonnes pratiques
- Créez une collection par cas d’usage ; évitez de mélanger les locataires.
- Activez la réplication locale si vous prévoyez des requêtes lourdes.
- Exportez vos collections avec `qdrant import/export` avant les mises à jour majeures.

## Exemples
```bash
curl -X POST \ 
  -H "api-key: $QDRANT_API_KEY" \ 
  -H "Content-Type: application/json" \ 
  -d '{"vectors": [0.1,0.2,0.3], "payload": {"who": "azoth"}}' \ 
  http://127.0.0.1:6303/collections/demo/points
```
Parce que les vecteurs aussi aiment avoir un badge nominatif.
