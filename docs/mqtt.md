# MQTT (Eclipse Mosquitto)

## Rôle
Bus de messages léger pour connecter capteurs, workflows n8n et services internes.

## Dépendances
- Fichiers de configuration dans `configs/mqtt/` (ACL, utilisateurs, TLS).
- Réseau `backbone_net`.

## Ports
- 1883 (MQTT sans TLS) – bind 127.0.0.1 par défaut.
- 8883 (MQTT avec TLS) – bind 127.0.0.1 par défaut.

## Volumes
- `mosquitto_data` → `/mosquitto/data`
- `mosquitto_log` → `/mosquitto/log`
- `./configs/mqtt/mosquitto.conf` → `/mosquitto/config/mosquitto.conf`

## Risques sécurité
- Comptes anonymes : désactiver `allow_anonymous` (déjà faux par défaut dans `.env.example`).
- TLS nécessaire si exposition LAN/Internet.
- ACL absentes → fuite de messages cross-tenant.

## Configuration recommandée
- Générer les utilisateurs via `mosquitto_passwd` (voir commentaire dans `configs/mqtt/passwords`).
- Créer des ACL par tenant (ex: `azoth/#`, `maximus/#`, `koff/#`).
- Pour TLS : générer un CA local + certs serveur dans `configs/mqtt/certs/` (non fournis). Exemple :
```
mkdir -p configs/mqtt/certs
openssl req -new -x509 -days 365 -nodes -out configs/mqtt/certs/ca.crt -keyout configs/mqtt/certs/ca.key
openssl req -new -nodes -out configs/mqtt/certs/server.csr -keyout configs/mqtt/certs/server.key
openssl x509 -req -in configs/mqtt/certs/server.csr -CA configs/mqtt/certs/ca.crt -CAkey configs/mqtt/certs/ca.key -CAcreateserial -out configs/mqtt/certs/server.crt -days 365
```

## Vérification rapide
```
docker compose exec mosquitto mosquitto_pub -t health -m ok
```
