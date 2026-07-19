# FIN-R - Plateforme d'Analyse de Raisonnement Cognitif

Plateforme web pour l'analyse et la détection du raisonnement cognitif chez les ingénieurs pendant les sessions de résolution de problèmes de conception.

## 🏗️ Architecture

Le projet est divisé en 3 parties principales :

- **finr-api/** - Backend Laravel (API REST)
- **finr-app/** - Frontend React (Interface utilisateur)
- **finr-nlp/** - Module NLP pour l'analyse de texte (Python)

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir installé :

- **PHP 8.1+** avec les extensions : pdo, mbstring, tokenizer, xml, curl, zip
- **Composer** (gestionnaire de dépendances PHP)
- **Node.js 16+** et **npm**
- **Git**

## 🚀 Installation et Configuration

### 1. Cloner le projet

```bash
git clone https://github.com/hamadou-abdoulaye/FIN-R.git
cd FIN-R
```

### 2. Configuration de la base de données

Le projet utilise **SQLite** par défaut pour la simplicité.

#### Option A : SQLite (recommandé pour le développement)

1. Copiez le fichier `.env.example` vers `.env` dans le dossier `finr-api/` :

```bash
cd finr-api
cp .env.example .env
```

2. Vérifiez que la configuration de la base de données dans `.env` est correcte :

```env
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite
```

3. Créez le fichier de base de données SQLite :

```bash
# Windows
type nul > database/database.sqlite

# Linux/Mac
touch database/database.sqlite
```

#### Option B : MySQL/PostgreSQL

Modifiez le fichier `finr-api/.env` avec vos paramètres :

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=finr_db
DB_USERNAME=root
DB_PASSWORD=votre_mot_de_passe
```

### 3. Installation du Backend (Laravel)

```bash
cd finr-api

# Installer les dépendances PHP
composer install

# Générer la clé d'application
php artisan key:generate

# Créer la base de données SQLite (si pas déjà fait)
echo "" > database/database.sqlite

# Exécuter les migrations
php artisan migrate

# (Optionnel) Peupler la base de données avec des données de test
php artisan db:seed

# Démarrer le serveur backend
php artisan serve
```

Le backend sera accessible sur `http://localhost:8000`

### 4. Installation du Frontend (React)

Ouvrez un nouveau terminal :

```bash
cd finr-app

# Installer les dépendances Node.js
npm install

# Démarrer le serveur de développement
npm start
```

Le frontend sera accessible sur `http://localhost:3000`

### 5. Configuration du module NLP (optionnel)

```bash
cd finr-nlp

# Créer un environnement virtuel Python
python -m venv venv

# Activer l'environnement virtuel
# Windows
venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt
```

## 📊 Structure de la Base de Données

### Tables principales

1. **users** - Utilisateurs (ingénieurs et chercheurs)
2. **engineers** - Informations spécifiques aux ingénieurs
3. **research_sessions** - Sessions de recherche/résolution
4. **reasoning_scores** - Scores de raisonnement par session
5. **session_events** - Événements cognitifs détectés

### Schéma des sessions

```
research_sessions
├── id
├── engineer_id (clé étrangère vers engineers)
├── problem (texte du problème)
├── notes (notes de l'ingénieur)
├── status (draft/active/paused/completed)
├── started_at
├── ended_at
├── creativity_score
└── timestamps

reasoning_scores
├── id
├── session_id (clé étrangère vers research_sessions)
├── type (Analytique, Créatif, Par analogie, etc.)
├── percentage (pourcentage de ce type de raisonnement)
└── timestamps

session_events
├── id
├── session_id (clé étrangère vers research_sessions)
├── type (decomposition, analogy, hesitation, insight, backtrack)
├── label (description de l'événement)
├── occurred_at (timestamp de l'événement)
└── metadata (données supplémentaires en JSON)
```

## 🔧 Configuration avancée

### Variables d'environnement importantes

Dans `finr-api/.env` :

```env
# Application
APP_NAME="FIN-R"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# Base de données
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite

# Session
SESSION_DRIVER=database
SESSION_LIFETIME=120

# Broadcast (pour les notifications en temps réel)
BROADCAST_DRIVER=log
QUEUE_CONNECTION=database
```

### Comptes de test

Après avoir exécuté `php artisan db:seed`, vous pouvez utiliser :

- **Ingénieur** : email `engineer@test.com` / mot de passe `password`
- **Chercheur** : email `researcher@test.com` / mot de passe `password`

## 🧪 Tests

```bash
# Backend
cd finr-api
php artisan test

# Frontend
cd finr-app
npm test
```

## 📦 Build de production

### Frontend

```bash
cd finr-app
npm run build
```

Les fichiers de build seront dans `finr-app/build/`

### Backend

```bash
cd finr-api
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## 🚢 Déploiement

### Backend (Laravel)

1. Configurez votre serveur web (Nginx/Apache) pour pointer vers `finr-api/public/`
2. Configurez une base de données MySQL/PostgreSQL en production
3. Exécutez les migrations : `php artisan migrate --force`
4. Configurez le queue worker pour les événements en temps réel

### Frontend (React)

1. Construisez l'application : `npm run build`
2. Déployez le contenu de `finr-app/build/` sur votre serveur web
3. Configurez le proxy pour rediriger les requêtes API vers le backend

## 🤝 Contribution

1. Forkez le projet
2. Créez une branche pour votre fonctionnalité : `git checkout -b feature/nouvelle-fonctionnalite`
3. Committez vos changements : `git commit -m "feat: ajout de nouvelle fonctionnalité"`
4. Poussez vers la branche : `git push origin feature/nouvelle-fonctionnalite`
5. Ouvrez une Pull Request

## 📝 Licence

Ce projet est sous licence MIT.

## 👥 Auteurs

- **Hamadou Abdoulaye** - *Développement initial*

## 📞 Support

Pour toute question ou problème, veuillez ouvrir une issue sur GitHub.

---

**Note** : Ce projet a été développé dans le cadre d'un stage de fin d'études.