# MQTT – le café serré des messages

Mosquitto fournit un bus simple pour vos capteurs ou événements internes.

## Connexion
- Broker : `127.0.0.1:${MQTT_PORT:-1883}`
- Pas de compte par défaut : ajoutez un fichier `mosquitto_passwd` dans `data/shared/mqtt/config` si vous ouvrez au public.

## Usages rapides
- Publication : `mosquitto_pub -h 127.0.0.1 -t demo/topic -m "hello"`
- Souscription : `mosquitto_sub -h 127.0.0.1 -t demo/#`

## Sécurité
- Activez le mot de passe si exposition externe via reverse-proxy TCP.
- Ajoutez du TLS si vous aimez dormir tranquille.
