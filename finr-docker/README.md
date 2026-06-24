# FIN-R — Déploiement Docker

Lance toute la stack FIN-R en **une commande**.

## Architecture

```
                    ┌──────────────┐
                    │    Nginx     │  :80
                    │ (proxy)      │
                    └──────┬───────┘
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐  /ws
        │  React   │ │ Laravel  │──────────► Reverb :8080
        │ frontend │ │   API    │               (WebSockets)
        └──────────┘ └────┬─────┘
                          │
              ┌───────────┼───────────┐
              ▼           ▼           ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │PostgreSQL│ │ NLP      │ │  Queue   │
        │  :5432   │ │ Python   │ │  Worker  │
        └──────────┘ │  :8001   │ └──────────┘
                     └──────────┘
```

## Prérequis

- Docker Desktop ≥ 24 (ou Docker Engine + Compose v2)
- 4 Go RAM minimum
- Ports libres : 80, 8080

## Démarrage rapide

```bash
# 1. Cloner / décompresser les 3 projets dans le même dossier
#    finr-app/   finr-api/   finr-nlp/   finr-docker/

# 2. Configurer les variables
cd finr-docker
cp .env.example .env
# → Éditer .env : changer les secrets (APP_KEY, JWT_SECRET, DB_PASSWORD...)

# 3. Lancer
make up
# ou : docker compose up --build -d

# 4. Ouvrir
open http://localhost
```

## Générer les clés

```bash
# APP_KEY Laravel
docker compose run --rm api php artisan key:generate --show

# JWT_SECRET
docker compose run --rm api php artisan jwt:secret --show
```

Copier les valeurs générées dans `.env`.

## Commandes utiles

```bash
make up           # démarrer
make down         # arrêter
make logs         # voir les logs
make shell-api    # shell Laravel
make shell-nlp    # shell Python
make test-nlp     # tests NLP (15 tests)
make reset        # tout effacer et recréer
```

## Services et ports

| Service     | Container       | Port interne | Port hôte |
|-------------|-----------------|-------------|-----------|
| Nginx       | finr_nginx      | 80          | **80**    |
| React       | finr_frontend   | 3000        | (interne) |
| Laravel API | finr_api        | 8000        | (interne) |
| Reverb WS   | finr_reverb     | 8080        | **8080**  |
| NLP Python  | finr_nlp        | 8001        | (interne) |
| PostgreSQL  | finr_postgres   | 5432        | (interne) |
| Queue worker| finr_worker     | —           | (interne) |

## Comptes de test (chargés automatiquement)

| Email              | Mot de passe | Rôle       |
|--------------------|-------------|------------|
| a.kone@esp.sn      | password    | researcher |
| a.mbaye@esp.sn     | password    | engineer   |
| o.diallo@esp.sn    | password    | engineer   |
| f.sow@esp.sn       | password    | engineer   |
| m.ba@esp.sn        | password    | engineer   |

## Déploiement en production (VPS)

```bash
# 1. Sur le serveur
git clone ... && cd finr-docker

# 2. .env production
cp .env.example .env
nano .env   # APP_ENV=production, APP_URL=https://votre-domaine.sn, vrais secrets

# 3. HTTPS avec Certbot (optionnel mais recommandé)
# → Ajouter un bloc ssl dans nginx/default.conf

# 4. Lancer
docker compose -f docker-compose.yml up -d --build
```

## Volumes persistants

| Volume        | Contenu                      |
|---------------|------------------------------|
| postgres_data | Toutes les données PostgreSQL |
| api_storage   | Fichiers Laravel (logs, cache)|

```bash
# Backup PostgreSQL
docker compose exec postgres pg_dump -U finr_user finr > backup.sql

# Restore
cat backup.sql | docker compose exec -T postgres psql -U finr_user finr
```
