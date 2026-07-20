# Déploiement sur InfinityFree (100% GRATUIT)

Guide complet pour déployer FIN-R sur InfinityFree sans carte bancaire.

## 📋 Prérequis

- Compte InfinityFree créé : [infinityfree.net](https://infinityfree.net)
- Compte GitHub avec le repo FIN-R
- Base de données MySQL locale à migrer

## 🚀 Étape 1 : Créer un compte InfinityFree

1. Aller sur [infinityfree.net](https://infinityfree.net)
2. Cliquer sur **"Sign Up"** en haut à droite
3. Remplir le formulaire d'inscription
4. Vérifier votre email (cliquez sur le lien de confirmation)
5. Se connecter au panel

## 🚀 Étape 2 : Créer un site web

1. Dans le panel InfinityFree, cliquer sur **"Create Account"** dans la section **"Hosting"**
2. Choisir un **sous-domaine** (ex: `finr-api` → `finr-api.infinityfreeapp.com`)
3. Choisir un **domaine personnalisé** (optionnel)
4. Cliquer sur **"Create Account"**
5. Attendre 2-3 minutes pour la création du compte
6. **Noter les informations importantes :**
   - URL du site : `https://finr-api.infinityfreeapp.com`
   - Identifiants MySQL (host, username, password, database name)

## 🚀 Étape 3 : Préparer le backend en local

### 3.1 Installer les dépendances et optimiser

```bash
# Windows (Git Bash ou WSL)
cd finr-api

# Installer les dépendances en mode production
composer install --no-dev --optimize-autoloader --no-interaction

# Générer la clé d'application
php artisan key:generate --force

# Optimiser pour la production
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 3.2 Configurer le fichier .env

Créer/modifier le fichier `finr-api/.env` :

```env
APP_NAME="FIN-R"
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:VOTRE_CLE_ICI
APP_URL=https://finr-api.infinityfreeapp.com

DB_CONNECTION=mysql
DB_HOST=sqlXXX.infinityfree.com
DB_PORT=3306
DB_DATABASE=nom_base_donnees
DB_USERNAME=utilisateur
DB_PASSWORD=mot_de_passe

SESSION_DRIVER=database
SESSION_LIFETIME=120

CORS_ALLOWED_ORIGINS=https://finr-app.vercel.app
```

**Remplacez les valeurs :**
- `sqlXXX.infinityfree.com` → Host MySQL fourni par InfinityFree
- `nom_base_donnees` → Nom de la base de données
- `utilisateur` → Nom d'utilisateur MySQL
- `mot_de_passe` → Mot de passe MySQL
- `VOTRE_CLE_ICI` → Clé générée par `php artisan key:generate --force`

### 3.3 Créer une archive ZIP

**Windows :**
1. Sélectionner tous les fichiers dans `finr-api/` (pas le dossier lui-même)
2. Clic droit → "Envoyer vers" → "Dossier compressé (zippé)"
3. Nommer le fichier : `finr-backend.zip`

**Linux/Mac :**
```bash
cd finr-api
zip -r ../finr-backend.zip . -x "node_modules/*" ".env" "storage/logs/*" "storage/framework/cache/*" "storage/framework/sessions/*" "storage/framework/views/*"
cd ..
```

## 🚀 Étape 4 : Créer la base de données sur InfinityFree

1. Dans InfinityFree, aller dans **"MySQL Databases"**
2. Cliquer sur **"Create Database"**
3. Donner un nom à la base (ex: `finr_db`)
4. Cliquer sur **"Create"**
5. **Noter les informations :**
   - Database Name
   - Username
   - Password
   - Host (ex: `sqlXXX.infinityfree.com`)

## 🚀 Étape 5 : Importer les données

### Option A : Si vous avez une base de données locale

```bash
# Exporter votre base locale
mysqldump -u root -p finr > finr_backup.sql
```

1. Dans InfinityFree, aller dans **"phpMyAdmin"**
2. Sélectionner votre base de données
3. Cliquer sur l'onglet **"Importer"**
4. Choisir le fichier `finr_backup.sql`
5. Cliquer sur **"Importer"**

### Option B : Si c'est une nouvelle base

1. Dans InfinityFree, aller dans **"phpMyAdmin"**
2. Sélectionner votre base de données
3. Aller dans l'onglet **"SQL"**
4. Exécuter le contenu du fichier `finr-api/database/migrations/2024_01_01_000001_create_finr_tables.php`
5. Exécuter le contenu du fichier `finr-api/database/seeders/DatabaseSeeder.php` (optionnel, pour les données de test)

## 🚀 Étape 6 : Uploader le backend sur InfinityFree

1. Dans InfinityFree, aller dans **"File Manager"**
2. Naviguer vers le dossier `htdocs/`
3. Supprimer tous les fichiers par défaut (index.php, etc.)
4. Cliquer sur **"Upload"** et sélectionner `finr-backend.zip`
5. Attendre la fin de l'upload
6. Sélectionner le fichier `finr-backend.zip` et cliquer sur **"Extract"**
7. Déplacer tous les fichiers du dossier `finr-api/` vers `htdocs/`
8. Supprimer le dossier `finr-api/` vide
9. Supprimer le fichier `finr-backend.zip`

**Résultat attendu :**
```
htdocs/
├── app/
├── bootstrap/
├── config/
├── database/
├── public/
├── resources/
├── routes/
├── storage/
├── tests/
├── .htaccess
├── artisan
├── composer.json
├── composer.lock
└── ...
```

## 🚀 Étape 7 : Configurer le fichier .env sur InfinityFree

1. Dans File Manager, naviguer vers `htdocs/`
2. Trouver le fichier `.env` (caché, cliquer sur "Show hidden files")
3. Cliquer sur **"Edit"** et modifier les valeurs :
   - `APP_URL` : `https://finr-api.infinityfreeapp.com`
   - `DB_HOST` : Host MySQL fourni par InfinityFree
   - `DB_DATABASE` : Nom de la base de données
   - `DB_USERNAME` : Nom d'utilisateur MySQL
   - `DB_PASSWORD` : Mot de passe MySQL
   - `APP_KEY` : La clé générée précédemment
4. Sauvegarder

## 🚀 Étape 8 : Configurer les permissions

1. Dans File Manager, naviguer vers `htdocs/storage/`
2. Cliquer sur **"Permissions"**
3. Mettre les permissions à **755** pour tous les dossiers
4. Mettre les permissions à **644** pour tous les fichiers

## 🚀 Étape 9 : Tester le backend

1. Ouvrir un navigateur
2. Aller sur : `https://finr-api.infinityfreeapp.com/api/health`
3. Vous devriez voir une réponse JSON

Si vous voyez une erreur 500 :
- Vérifier les logs dans InfinityFree → "Error Logs"
- Vérifier que le fichier `.env` est correctement configuré
- Vérifier que la base de données est accessible

## 🚀 Étape 10 : Déployer le frontend sur Vercel

1. Aller sur [vercel.com](https://vercel.com) et créer un compte
2. Cliquer sur **"Add New..." → "Project"**
3. Importer le repo `FIN-R`
4. **Root Directory** : `finr-app`
5. **Ajouter la variable d'environnement :**
   - `REACT_APP_API_URL` = `https://finr-api.infinityfreeapp.com/api`
6. Cliquer sur **"Deploy"**
7. Attendre 2-3 minutes

## 🚀 Étape 11 : Tester l'application complète

1. **Frontend** : `https://finr-app.vercel.app`
2. **Backend** : `https://finr-api.infinityfreeapp.com`
3. **Login** : `engineer@test.com` / `password`

## 🔧 Dépannage

### Erreur 500 - Internal Server Error

**Solution :**
1. Vérifier les logs dans InfinityFree → "Error Logs"
2. Vérifier que `APP_KEY` est défini dans `.env`
3. Vérifier que les permissions de `storage/` sont correctes (755)
4. Vérifier que la base de données est accessible

### Erreur de connexion à la base de données

**Solution :**
1. Vérifier les credentials dans `.env`
2. Vérifier que la base de données existe sur InfinityFree
3. Vérifier que l'utilisateur MySQL a les droits sur la base

### Erreur CORS

**Solution :**
1. Vérifier que `CORS_ALLOWED_ORIGINS` contient l'URL du frontend
2. Vérifier que l'URL se termine par `/` (pas de slash à la fin)

### Le frontend ne peut pas appeler l'API

**Solution :**
1. Vérifier `REACT_APP_API_URL` dans Vercel
2. Vérifier que l'URL se termine par `/api`
3. Vérifier CORS sur le backend

## 📊 Maintenance

### Mettre à jour l'application

**Backend :**
1. Modifier le code en local
2. Optimiser : `composer install --no-dev --optimize-autoloader && php artisan config:cache && php artisan route:cache && php artisan view:cache`
3. Créer un nouveau ZIP
4. Uploader sur InfinityFree et extraire
5. Mettre à jour le fichier `.env` si nécessaire

**Frontend :**
1. Modifier le code en local
2. Pousser sur GitHub
3. Vercel redéploiera automatiquement

### Sauvegardes

**Base de données :**
1. Aller dans phpMyAdmin sur InfinityFree
2. Sélectionner la base de données
3. Cliquer sur **"Exporter"**
4. Télécharger le fichier SQL

## ⚠️ Limitations d'InfinityFree

- Mise en veille après 30 min d'inactivité
- Support limité (pas de support prioritaire)
- Performance variable selon le trafic
- Pas de SSH accessible
- Limites de ressources (suffisant pour un petit projet)

## ✅ Avantages

- 100% gratuit, pas de carte bancaire
- PHP 8.1+ supporté
- MySQL 5.7+ inclus
- SSL gratuit (Let's Encrypt)
- Bande passante illimitée
- Espace disque illimité
- Pas de publicité
- Support phpMyAdmin

## 🎉 Félicitations !

Votre application FIN-R est maintenant en ligne et accessible gratuitement !

**URLs :**
- Frontend : `https://finr-app.vercel.app`
- Backend : `https://finr-api.infinityfreeapp.com`
- Login : `engineer@test.com` / `password`

---

**Note :** Ce projet a été développé dans le cadre d'un stage de fin d'études.