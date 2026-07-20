#!/bin/bash

# Script de déploiement pour InfinityFree
# Usage: ./deploy-infinityfree.sh

echo "🚀 Déploiement de FIN-R sur InfinityFree"
echo "========================================"
echo ""

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Vérifier que nous sommes dans le bon répertoire
if [ ! -d "finr-api" ]; then
    echo -e "${RED}❌ Erreur: Ce script doit être exécuté depuis la racine du projet FIN-R${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Étape 1: Installation des dépendances et optimisation${NC}"
cd finr-api

# Installer les dépendances en mode production
echo "Installation des dépendances Composer..."
composer install --no-dev --optimize-autoloader --no-interaction

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur lors de l'installation des dépendances${NC}"
    exit 1
fi

# Générer la clé d'application
echo "Génération de la clé d'application..."
php artisan key:generate --force

# Optimiser pour la production
echo "Optimisation de Laravel..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo -e "${GREEN}✅ Backend optimisé${NC}"
echo ""

# Retour à la racine
cd ..

echo -e "${YELLOW}📦 Étape 2: Construction du frontend${NC}"
cd finr-app

# Installer les dépendances
echo "Installation des dépendances npm..."
npm install

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur lors de l'installation des dépendances npm${NC}"
    exit 1
fi

# Construire pour la production
echo "Construction de l'application React..."
npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erreur lors de la construction du frontend${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Frontend construit${NC}"
echo ""

# Retour à la racine
cd ..

echo -e "${YELLOW}📦 Étape 3: Création des archives de déploiement${NC}"

# Créer un dossier temporaire
mkdir -p deploy-temp

# Copier le backend
echo "Copie du backend..."
cp -r finr-api deploy-temp/backend

# Copier le build du frontend
echo "Copie du frontend..."
cp -r finr-app/build deploy-temp/frontend

# Créer les archives
echo "Création des archives ZIP..."
cd deploy-temp

zip -r ../finr-backend.zip backend -x "backend/node_modules/*" "backend/.env" "backend/storage/logs/*" "backend/storage/framework/cache/*" "backend/storage/framework/sessions/*" "backend/storage/framework/views/*"

zip -r ../finr-frontend.zip frontend

cd ..

# Nettoyer le dossier temporaire
rm -rf deploy-temp

echo -e "${GREEN}✅ Archives créées:${NC}"
echo "   - finr-backend.zip (Backend Laravel)"
echo "   - finr-frontend.zip (Frontend React)"
echo ""

echo -e "${YELLOW}📤 Étape 4: Instructions d'upload${NC}"
echo ""
echo -e "${GREEN}1. Backend (Laravel):${NC}"
echo "   - Aller sur InfinityFree → File Manager"
echo "   - Naviguer vers htdocs/"
echo "   - Supprimer tous les fichiers par défaut"
echo "   - Uploader finr-backend.zip"
echo "   - Extraire le fichier"
echo "   - Déplacer tous les fichiers de backend/ vers htdocs/"
echo "   - Supprimer le dossier backend/"
echo ""
echo -e "${GREEN}2. Frontend (React):${NC}"
echo "   - Dans InfinityFree File Manager"
echo "   - Créer un dossier 'app' dans htdocs/"
echo "   - Uploader finr-frontend.zip dans htdocs/app/"
echo "   - Extraire le fichier"
echo "   - Déplacer tous les fichiers vers htdocs/app/"
echo ""
echo -e "${YELLOW}⚠️  N'oubliez pas de configurer le fichier .env avec vos credentials InfinityFree !${NC}"
echo ""
echo -e "${GREEN}✅ Déploiement préparé avec succès !${NC}"
echo ""
echo "Prochaines étapes:"
echo "1. Uploader finr-backend.zip sur InfinityFree"
echo "2. Configurer le fichier .env avec les credentials InfinityFree"
echo "3. Créer la base de données MySQL sur InfinityFree"
echo "4. Importer les données via phpMyAdmin"
echo "5. Uploader finr-frontend.zip"
echo "6. Tester l'application"