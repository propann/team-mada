# MQTT (Eclipse Mosquitto)

## Rôle
Broker MQTT partagé pour la messagerie temps réel inter-services/tenants.

## Dépendances
- Aucun service applicatif, nécessite les fichiers de configuration montés depuis `configs/mqtt/`.

## Ports
- 1883 (TCP) : MQTT non chiffré (lié sur 127.0.0.1).
- 8883 (TCP) : MQTT TLS (lié sur 127.0.0.1), activé si les certificats sont présents.

## Volumes
- Mono-instance : `mosquitto_data` → `/mosquitto/data`, `mosquitto_log` → `/mosquitto/log`
- Multi-tenant : `./data/shared/mqtt` pour data + `./data/shared/mqtt/config` pour config
- Fichiers montés :
  - `configs/mqtt/mosquitto.conf` → `/mosquitto/config/mosquitto.conf`
  - `configs/mqtt/acl` → `/mosquitto/config/acl`
  - `configs/mqtt/passwords` → `/mosquitto/config/passwords`
  - `configs/mqtt/certs/*` → `/mosquitto/config/certs/`

## Risques sécurité
- Accès anonyme si `MOSQUITTO_ALLOW_ANONYMOUS=true`.
- Fuite inter-tenant en cas d’ACL permissives.
- Certificats TLS absents ou mal protégés.

## Configuration recommandée
- Laisser `MOSQUITTO_ALLOW_ANONYMOUS=false` (défaut) et gérer les comptes via `mosquitto_passwd`.
- Segmentation des topics par tenant dans `acl` (`tenant/#`).
- Générer des certificats auto-signés ou Let’s Encrypt pour `configs/mqtt/certs` (ne pas committer). Exemple :
```
mkdir -p configs/mqtt/certs
openssl req -x509 -newkey rsa:4096 -keyout configs/mqtt/certs/server.key -out configs/mqtt/certs/server.crt -days 365 -nodes -subj "/CN=mqtt.local"
openssl req -x509 -newkey rsa:4096 -keyout configs/mqtt/certs/ca.key -out configs/mqtt/certs/ca.crt -days 365 -nodes -subj "/CN=mqtt-ca"
```
- Vérifier les permissions (root:root, 600) sur les clés privées.

## Vérification rapide
```
docker compose -f compose/stack.yml ps mosquitto
docker compose -f compose/stack.yml exec mosquitto mosquitto_sub -h localhost -p ${MOSQUITTO_PORT:-1883} -t health -C 1 -W 3
```
