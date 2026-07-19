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

## 🚢 Déploiement sur hébergeur en ligne

### Option 0 : Hébergement GRATUIT (pour tests et démonstration)

#### 🎯 Meilleure option : Render + Vercel + Aiven

**Stack recommandée :**
- **Backend** : Laravel sur Render (Gratuit)
- **Frontend** : React sur Vercel (Gratuit)
- **Base de données** : PostgreSQL sur Aiven (Gratuit pour toujours)

**Limites :**
- Render Free : 512 MB RAM, 100 GB bandwidth/mois, mise en veille après 15 min d'inactivité
- Vercel Free : 100 GB bandwidth/mois, illimité pour projets personnels
- Aiven Free : 500 MB stockage, 10 connexions simultanées, gratuit pour toujours

---

## 📋 Guide de déploiement ULTRA-SIMPLIFIÉ

### Étape 1 : Migrer votre base de données MySQL locale vers Aiven (5 minutes)

**Si vous avez déjà une base de données MySQL locale** (comme la vôtre avec `finr`), suivez ces étapes :

1. **Exporter votre base de données locale :**

```bash
# Dans le terminal, depuis votre installation MySQL locale
mysqldump -u root -p finr > finr_backup.sql
```

2. **Créer un compte sur [aiven.io](https://aiven.io)** et créer un service MySQL :
   - "Create service" → "MySQL" → Plan "Free"
   - Noter le **Service URI** (ex: `mysql://avnadmin:password@host:3306/defaultdb`)

3. **Importer votre base de données vers Aiven :**

```bash
# Installer le client Aiven (si pas déjà fait)
# Windows : télécharger depuis aiven.io/docs/tools/avncli

# Ou utiliser mysql directement avec les credentials Aiven
mysql -h host.aivencloud.com -u avnadmin -p finr_db < finr_backup.sql
```

4. **Vérifier l'importation :**
   - Aller dans Aiven → "Query"
   - Exécuter : `SHOW TABLES;`
   - Vous devriez voir toutes vos tables (users, engineers, research_sessions, etc.)

**Si vous n'avez pas de base de données existante**, créez-en une neuve sur Aiven :
- Aller dans "Query" sur Aiven
- Exécuter : `CREATE DATABASE finr_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`

### Étape 2 : Déployer le backend sur Render (5 minutes)

1. **Aller sur [render.com](https://render.com)** et créer un compte
2. **"New +" → "Static Site"**
3. **Connecter votre repo GitHub** : `hamadou-abdoulaye/FIN-R`
4. **Configurer :**
   - **Name** : `finr-api`
   - **Build Command** : `cd finr-api && composer install --no-dev --optimize-autoloader && php artisan key:generate && php artisan migrate --force`
   - **Publish Directory** : `finr-api/public`
5. **Ajouter les variables d'environnement :**
   - `APP_ENV` = `production`
   - `APP_DEBUG` = `false`
   - `APP_KEY` = (générer avec `php artisan key:generate --show` en local)
   - `APP_URL` = `https://finr-api.onrender.com`
   - `DB_CONNECTION` = `mysql`
   - `DB_HOST` = (host depuis Aiven)
   - `DB_PORT` = `3306`
   - `DB_DATABASE` = `finr_db`
   - `DB_USERNAME` = `avnadmin`
   - `DB_PASSWORD` = (password depuis Aiven)
   - `SESSION_DRIVER` = `database`
   - `CORS_ALLOWED_ORIGINS` = `https://finr-app.vercel.app`
6. **"Create Static Site"** et attendre 3-5 minutes

### Étape 3 : Déployer le frontend sur Vercel (3 minutes)

1. **Aller sur [vercel.com](https://vercel.com)** et créer un compte
2. **"Add New..." → "Project"**
3. **Importer** le repo `FIN-R`
4. **Root Directory** : `finr-app`
5. **Ajouter la variable d'environnement :**
   - `REACT_APP_API_URL` = `https://finr-api.onrender.com/api`
6. **"Deploy"** et attendre 2-3 minutes

### Étape 4 : Tester (1 minute)

- **Frontend** : `https://finr-app.vercel.app`
- **Backend** : `https://finr-api.onrender.com`
- **Login** : `engineer@test.com` / `password`

**C'est tout !** 🎉

### Étape 7 : Configurer un nom de domaine personnalisé (optionnel)

**Pour le backend (Render) :**
1. Aller dans Render → finr-api → Settings → Custom Domains
2. Ajouter votre domaine : `api.votre-domaine.com`
3. Configurer les DNS chez votre registrar :
   - Type : CNAME
   - Name : api
   - Value : finr-api.onrender.com

**Pour le frontend (Vercel) :**
1. Aller dans Vercel → finr-app → Settings → Domains
2. Ajouter votre domaine : `votre-domaine.com`
3. Configurer les DNS :
   - Type : A
   - Name : @
   - Value : 76.76.21.21 (IP Vercel)
   - Type : CNAME
   - Name : www
   - Value : cname.vercel-dns.com

### Étape 8 : Activer les notifications (optionnel)

Pour les notifications en temps réel avec Reverb :

1. **Ajouter Reverb sur Render :**
   - Créer un nouveau "Web Service"
   - Runtime : PHP
   - Build Command : `composer install --no-dev`
   - Start Command : `php artisan reverb:start --host=0.0.0.0 --port=8080`
   - Plan : Free

2. **Configurer les variables d'environnement :**
   - `REVERB_APP_ID` : `finr-app`
   - `REVERB_APP_KEY` : `finr-key` (générer un nouveau)
   - `REVERB_APP_SECRET` : `finr-secret` (générer un nouveau)

3. **Mettre à jour le frontend :**
   - Ajouter dans Vercel :
     - `REACT_APP_REVERB_HOST` = `finr-reverb.onrender.com`
     - `REACT_APP_REVERB_PORT` = `8080`
     - `REACT_APP_REVERB_KEY` = `finr-key`

---

## 🔧 Dépannage

### Problème : Le backend ne démarre pas

**Solution :**
1. Vérifier les logs dans Render Dashboard
2. Vérifier que `APP_KEY` est défini
3. Vérifier que les migrations ont été exécutées

### Problème : Erreur CORS

**Solution :**
1. Vérifier que `CORS_ALLOWED_ORIGINS` contient l'URL du frontend
2. Redéployer le backend après modification

### Problème : La base de données ne se connecte pas

**Solution :**
1. Vérifier les credentials dans Render Dashboard
2. Vérifier que `DB_CONNECTION=pgsql` (pas mysql)
3. Vérifier que les migrations ont été exécutées

### Problème : Le frontend ne peut pas appeler l'API

**Solution :**
1. Vérifier `REACT_APP_API_URL` dans Vercel
2. Vérifier que l'URL se termine par `/api`
3. Vérifier CORS sur le backend

---

## 📊 Monitoring et maintenance

### Surveiller l'application

**Render :**
- Logs en temps réel dans le Dashboard
- Métriques : CPU, RAM, Bandwidth
- Alertes par email en cas d'erreur

**Vercel :**
- Analytics intégrés
- Logs de déploiement
- Performance monitoring

### Mettre à jour l'application

**Backend :**
- Push sur GitHub → Render redéploie automatiquement
- Ou cliquer sur "Manual Deploy" dans Render Dashboard

**Frontend :**
- Push sur GitHub → Vercel redéploie automatiquement
- Ou cliquer sur "Deploy" dans Vercel Dashboard

### Sauvegardes

**Base de données PostgreSQL :**
- Render fait des sauvegardes automatiques (plan Free)
- Pour exporter : `pg_dump` via Render Shell

**Fichiers uploadés :**
- Render stocke dans un volume persistant
- Télécharger via Render Dashboard ou SFTP

---

## 💰 Coûts à long terme

**Phase 1 : Gratuit (0$/mois)**
- Render Free + Vercel Free
- Parfait pour : Tests, démonstration, MVP
- Limitations : Mise en veille après 15 min d'inactivité

**Phase 2 : Croissance (7$/mois)**
- Render Starter (7$/mois) : Pas de mise en veille, plus de ressources
- Vercel Free suffit généralement
- PostgreSQL sur Render : 7$/mois (après 90 jours)

**Phase 3 : Production (25+/mois)**
- Render Standard (25$/mois) : Performance professionnelle
- Vercel Pro (20$/mois) : Analytics avancés
- Base de données managée : 15-30$/mois

---

## ✅ Checklist de déploiement

- [ ] Compte Render créé
- [ ] Compte Vercel créé
- [ ] Backend déployé sur Render
- [ ] Base de données PostgreSQL créée
- [ ] Migrations exécutées
- [ ] Frontend déployé sur Vercel
- [ ] CORS configuré
- [ ] Application testée
- [ ] Nom de domaine configuré (optionnel)
- [ ] SSL activé (automatique)
- [ ] Monitoring activé

---

**Félicitations !** Votre application FIN-R est maintenant en ligne et accessible gratuitement !

#### Alternative : Fly.io (Gratuit pour petits projets)

```bash
# 1. Installer Fly CLI
curl -L https://fly.io/install.sh | sh

# 2. Se connecter
fly auth login

# 3. Lancer l'application
cd finr-api
fly launch
```

Fly.io offre :
- 3 VMs partagées gratuites
- 160 GB bandwidth/mois
- PostgreSQL gratuit (3GB stockage)

#### Alternative : Railway (Gratuit avec crédits)

```bash
# 1. Créer un compte sur railway.app
# 2. Connecter GitHub
# 3. Déployer finr-api et finr-nlp
# 4. Ajouter PostgreSQL
```

Railway offre 5$ de crédit gratuit/mois (suffisant pour un petit projet).

### Option 1 : Hébergement mutualisé (OVH, Hostinger, etc.)

#### Backend Laravel

1. **Préparer le backend en local :**

```bash
cd finr-api

# Installer les dépendances en mode production
composer install --no-dev --optimize-autoloader

# Générer la clé d'application
php artisan key:generate

# Créer le fichier .env de production
cp .env.example .env
# Éditer .env avec les paramètres de production :
# - APP_ENV=production
# - APP_DEBUG=false
# - DB_CONNECTION=mysql (ou pgsql)
# - DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD

# Exécuter les migrations
php artisan migrate --force

# Optimiser pour la production
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

2. **Uploader sur l'hébergeur :**

- Compresser le dossier `finr-api/` en `finr-api.zip`
- Uploader via FTP/SFTP dans le dossier `public_html/` ou `www/`
- Extraire le dossier
- Créer un fichier `.env` avec les paramètres de production
- Créer la base de données MySQL sur l'hébergeur
- Exécuter les migrations via SSH ou un script PHP

3. **Configuration du serveur web :**

Si votre hébergeur utilise Apache, créer un fichier `.htaccess` dans `finr-api/public/` :

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ index.php/$1 [L]
</IfModule>
```

#### Frontend React

1. **Construire l'application :**

```bash
cd finr-app

# Installer les dépendances
npm install

# Construire pour la production
npm run build
```

2. **Uploader le build :**

- Le dossier `finr-app/build/` contient les fichiers statiques
- Uploader le contenu de `build/` dans le dossier `public_html/` de l'hébergeur
- Ou dans un sous-dossier comme `public_html/app/`

3. **Configurer les URLs :**

Modifier `finr-app/src/lib/api.ts` pour pointer vers votre URL de production :

```typescript
const API_URL = process.env.REACT_APP_API_URL || 'https://votre-domaine.com/api';
```

Puis reconstruire : `npm run build`

### Option 2 : VPS (DigitalOcean, Vultr, OVH VPS, etc.)

#### Prérequis

- Ubuntu 22.04 ou Debian 12
- Accès SSH
- Nom de domaine pointant vers le serveur

#### Installation complète

```bash
# 1. Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# 2. Installer les dépendances
sudo apt install -y nginx mysql-server php8.2 php8.2-cli php8.2-fpm php8.2-mysql php8.2-mbstring php8.2-xml php8.2-curl php8.2-zip php8.2-bcmath php8.2-gd nodejs npm git unzip

# 3. Installer Composer
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# 4. Créer la base de données MySQL
sudo mysql -u root -p
CREATE DATABASE finr_db;
CREATE USER 'finr_user'@'localhost' IDENTIFIED BY 'votre_mot_de_passe';
GRANT ALL PRIVILEGES ON finr_db.* TO 'finr_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# 5. Cloner le projet
cd /var/www
sudo git clone https://github.com/hamadou-abdoulaye/FIN-R.git
sudo chown -R $USER:$USER FIN-R
cd FIN-R

# 6. Configurer le backend
cd finr-api
cp .env.example .env
# Éditer .env avec les paramètres de production
nano .env

composer install --no-dev --optimize-autoloader
php artisan key:generate
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 7. Configurer Nginx pour Laravel
sudo nano /etc/nginx/sites-available/finr-api
```

Configuration Nginx (`/etc/nginx/sites-available/finr-api`) :

```nginx
server {
    listen 80;
    server_name api.votre-domaine.com;
    root /var/www/FIN-R/finr-api/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

```bash
# 8. Activer la configuration
sudo ln -s /etc/nginx/sites-available/finr-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# 9. Configurer SSL avec Let's Encrypt
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d api.votre-domaine.com

# 10. Déployer le frontend
cd /var/www/FIN-R/finr-app
npm install
npm run build

# Copier le build vers le dossier web
sudo cp -r build/* /var/www/html/
```

Configuration Nginx pour le frontend (`/etc/nginx/sites-available/finr-frontend`) :

```nginx
server {
    listen 80;
    server_name votre-domaine.com;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxy pour l'API
    location /api {
        proxy_pass http://api.votre-domaine.com;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Cache pour les assets statiques
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

```bash
# 11. Activer et sécuriser
sudo ln -s /etc/nginx/sites-available/finr-frontend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
sudo certbot --nginx -d votre-domaine.com

# 12. Configurer les permissions
sudo chown -R www-data:www-data /var/www/FIN-R/finr-api/storage
sudo chmod -R 775 /var/www/FIN-R/finr-api/storage
```

### Option 3 : Plateformes PaaS (Laravel Forge, Vapor, etc.)

#### Laravel Forge

1. Créer un compte sur [Laravel Forge](https://forge.laravel.com/)
2. Connecter votre serveur VPS
3. Créer un nouveau site
4. Forge installera automatiquement :
   - Nginx
   - PHP
   - MySQL
   - Composer
   - SSL

5. Déployer via Git :
   - Connecter votre dépôt GitHub
   - Forge clonera et déploiera automatiquement
   - Configurer les variables d'environnement dans Forge

#### Vercel / Netlify (Frontend uniquement)

Pour déployer seulement le frontend React :

```bash
# Installer Vercel CLI
npm i -g vercel

# Déployer
cd finr-app
vercel --prod
```

### Configuration de production importante

#### Variables d'environnement (.env)

```env
# Application
APP_NAME="FIN-R"
APP_ENV=production
APP_KEY=base64:GENERATED_KEY
APP_DEBUG=false
APP_URL=https://votre-domaine.com

# Base de données
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=finr_db
DB_USERNAME=finr_user
DB_PASSWORD=mot_de_passe_securise

# Session
SESSION_DRIVER=database
SESSION_LIFETIME=120

# JWT (si utilisé)
JWT_SECRET=generated_jwt_secret

# CORS
CORS_ALLOWED_ORIGINS=https://votre-domaine.com
```

#### Sécurité

1. **Désactiver APP_DEBUG en production**
2. **Utiliser HTTPS** (Let's Encrypt gratuit)
3. **Configurer CORS** pour n'autoriser que votre domaine
4. **Protéger le dossier storage/** en écriture uniquement
5. **Utiliser des mots de passe forts** pour la base de données
6. **Mettre à jour régulièrement** les dépendances

### Vérification post-déploiement

```bash
# Tester l'API
curl https://api.votre-domaine.com/api/health

# Tester le frontend
 Ouvrir https://votre-domaine.com dans le navigateur

# Vérifier les logs Laravel
tail -f finr-api/storage/logs/laravel.log
```

### Support et troubleshooting

- **Erreur 500** : Vérifier les logs Laravel et les permissions
- **Erreur 404** : Vérifier la configuration Nginx/Apache
- **API ne répond pas** : Vérifier que le serveur PHP fonctionne
- **Base de données** : Vérifier les migrations et les credentials

Pour plus d'aide, consultez la documentation officielle :
- [Laravel Deployment](https://laravel.com/docs/deployment)
- [React Deployment](https://create-react-app.dev/docs/deployment/)

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