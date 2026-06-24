-- postgres/init.sql
-- Exécuté une seule fois à la création du volume.
-- Laravel gère les tables via les migrations (artisan migrate).

-- Extensions utiles
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "unaccent";   -- pour la recherche sans accents

-- Créer la DB si elle n'existe pas déjà (cas de reset)
SELECT 'CREATE DATABASE finr'
  WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'finr')\gexec
