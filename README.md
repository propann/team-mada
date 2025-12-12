# 🌐 Projet VPS – Plateforme Modulaire d’Automatisation & Création  
*Un atelier numérique pour apprendre, automatiser et expérimenter.*

---

## 🎯 Objectif du Projet

Ce dépôt documente la mise en place d'une plateforme technique sur VPS permettant :

- d’installer **n8n** pour créer et exécuter des workflows automatisés,  
- de visualiser des données techniques via **Grafana**,  
- de stocker ces données dans **InfluxDB**,  
- d’héberger **Strudel** pour explorer la musique générative en JavaScript,  
- de servir de base d’apprentissage : Docker, JS, automatisation, monitoring, bonnes pratiques.

Le projet doit rester **reproductible**, **pédagogique**, et **ne contenir aucune information sensible**.

---

## 🏗️ Architecture du Projet

┌─────────────────────────────────────────────────────────┐
│ VPS │
├─────────────────────────────────────────────────────────┤
│ Debian / Docker │
│ ├── n8n → Automatisation & workflows │
│ ├── InfluxDB → Stockage d'événements │
│ ├── Grafana → Tableaux de bord │
│ ├── Strudel Server → Audio JS / musique générative │
│ ├── Portainer → Gestion Docker │
│ └── Services internes (logs, monitoring) │
Chaque module est isolé, simple à maintenir, et pensé pour évoluer.

---

## 🔧 Services Inclus

### **1. Docker & Portainer**
Base de l’infrastructure.  
Permet de déployer et gérer facilement les conteneurs.

---

### **2. n8n – Automatisation accessible**
Utilisé pour :

- créer des workflows pédagogiques,  
- apprendre les API, webhooks, logique d'automatisation,  
- orchestrer des tâches internes,  
- construire un environnement formateur pour les débutants comme pour les créateurs.

Aucune donnée privée n'est intégrée dans les workflows.

---

### **3. Grafana – Vision globale du système**
Serve pour :

- analyser performances et comportements du VPS,  
- interpréter les données stockées dans InfluxDB,  
- visualiser l’activité des workflows.

Dashboards exportables et reproductibles.

---

### **4. InfluxDB – Stockage temporel**
Base utilisée pour des données **techniques anonymes**, comme :

- logs,  
- métriques système,  
- événements pédagogiques émis par n8n.

---

### **5. Strudel – Serveur de musique générative JS**
Espace créatif pour apprendre :

- JavaScript,  
- logique musicale,  
- génération algorithmique,  
- intégration possible avec n8n.

Documentation fournie dans `/docs/strudel/`.

---

## 📚 Documentation Prévue

Ce dépôt inclut une structure claire pour documenter l’installation, l’usage et la maintenance :


└─────────────────────────────────────────────────────────┘/docs
├─ install/ → guides d’installation pas-à-pas
├─ n8n/ → workflows, nodes, tutoriels
├─ grafana/ → dashboards & guides
├─ influxdb/ → schémas & bonnes pratiques
├─ strudel/ → scripts & tutoriels JS audio
├─ security/ → bonnes pratiques de sécurité VPS
└─ contribution.md → comment contribuer proprement
Chaque guide est pensé pour être **clair**, **reproductible**, et **sans données sensibles**.

---

## 🛠️ Mise en Place (Overview)

Les étapes détaillées sont disponibles dans `/docs/install/`.

1. Installer Docker  
2. Installer Portainer  
3. Déployer les services avec `docker-compose`  
4. Configurer n8n  
5. Configurer Grafana  
6. Configurer InfluxDB  
7. Installer Strudel  
8. Sécuriser le VPS  
9. Mettre en place les sauvegardes et les mises à jour

---

## 🤝 Philosophie

> *« Ce serveur n’est pas une tour d’ivoire.  
> C’est une forge où workflows, données et musique  
> deviennent les outils d’un futur que l’on construit à la main. »*

Le but : apprendre, documenter, transmettre.  
Créer une plateforme solide, propre, évolutive.

---

## 🚀 Feuille de Route

- Ajout de templates de workflows n8n  
- Scripts Strudel de démonstration  
- Documentation JS pour débutants  
- Exemples d’utilisation d’API publiques  
- Guide “Découverte de Docker”  
- Création d’un mini-site d’accueil pour la documentation

---

## 📜 Licence

Projet documentaire et éducatif.  
Libre d’adaptation, utilisation et distribution tant que les bonnes pratiques de sécurité sont respectées.





