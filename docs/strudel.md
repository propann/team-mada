# Strudel – l’atelier groove

Strudel sert des patches musicaux JS côté serveur. Idéal pour tester vos séquences pendant que les workflows tournent.

## Accès
- `http://127.0.0.1:8080`

## Utilisation rapide
- Montez vos scripts dans `data/shared/strudel/` (le dossier est monté dans l’image si vous l’activez dans compose).
- Exemple de boucle minimaliste :
```js
play('bd sn', 120)
```

## Pro tips
- Ajoutez un bus MIDI virtuel si vous voulez faire danser vos IoT. Oui, même le frigo.
- Surveillez la consommation CPU quand vous empilez les oscillateurs : Strudel aime les solos, moins les orages.
