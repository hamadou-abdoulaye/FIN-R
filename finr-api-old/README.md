# FIN-R API — Backend Laravel 11

API REST pour la plateforme FIN-R d'analyse du raisonnement en STEAM.

## Stack
- **Laravel 11** + PHP 8.3
- **PostgreSQL** (base de données principale)
- **JWT** via `tymon/jwt-auth` (authentification)
- **Laravel Reverb** (WebSockets temps réel)
- **NLP microservice** Python sur `localhost:8001`

---

## Installation rapide

### 1. Prérequis
```bash
php 8.2+
composer
postgresql
```

### 2. Cloner et installer
```bash
cd finr-api
composer install
cp .env.example .env
php artisan key:generate
php artisan jwt:secret
```

### 3. Base de données PostgreSQL
```sql
CREATE DATABASE finr;
CREATE USER finr_user WITH ENCRYPTED PASSWORD 'finr_secret';
GRANT ALL PRIVILEGES ON DATABASE finr TO finr_user;
```

### 4. Migrations + données de test
```bash
php artisan migrate
php artisan db:seed
```

### 5. Lancer le serveur
```bash
php artisan serve          # API sur :8000
php artisan reverb:start   # WebSockets sur :8080
```

---

## Endpoints API

### Auth
| Méthode | URL | Description |
|---------|-----|-------------|
| POST | `/api/auth/register` | Créer un compte |
| POST | `/api/auth/login` | Connexion → JWT |
| POST | `/api/auth/logout` | Invalider le token |
| POST | `/api/auth/refresh` | Renouveler le token |
| GET  | `/api/auth/me` | Profil courant |

### Ingénieurs (chercheur uniquement)
| Méthode | URL | Description |
|---------|-----|-------------|
| GET    | `/api/engineers` | Liste |
| POST   | `/api/engineers` | Créer |
| GET    | `/api/engineers/{id}` | Détail |
| PUT    | `/api/engineers/{id}` | Modifier |
| DELETE | `/api/engineers/{id}` | Supprimer |

### Sessions
| Méthode | URL | Description |
|---------|-----|-------------|
| GET    | `/api/sessions` | Liste (filtre: `?engineer_id=` `?status=`) |
| POST   | `/api/sessions` | Créer |
| GET    | `/api/sessions/{id}` | Détail complet |
| POST   | `/api/sessions/{id}/start` | Démarrer |
| POST   | `/api/sessions/{id}/pause` | Mettre en pause |
| POST   | `/api/sessions/{id}/end` | Terminer |
| PATCH  | `/api/sessions/{id}/notes` | Mettre à jour les notes (déclenche NLP) |
| DELETE | `/api/sessions/{id}` | Supprimer |
| GET    | `/api/sessions/stats/global` | Statistiques globales |

---

## Authentification

Toutes les requêtes (sauf login/register) nécessitent :
```
Authorization: Bearer <JWT_TOKEN>
```

### Rôles
- `researcher` — accès complet (dashboard, ingénieurs, stats)
- `engineer` — accès à ses propres sessions uniquement

---

## WebSockets (temps réel)

Le canal `session.{id}` diffuse l'événement `session.updated` à chaque
analyse NLP. Le front React s'y abonne via Laravel Echo + Reverb.

```javascript
// Dans le Workspace React
import Echo from 'laravel-echo';

const echo = new Echo({
    broadcaster: 'reverb',
    key: process.env.REACT_APP_REVERB_KEY,
    wsHost: process.env.REACT_APP_REVERB_HOST,
    wsPort: 8080,
});

echo.channel(`session.${sessionId}`)
    .listen('.session.updated', (data) => {
        setReasoning(data.reasoning);
        setCreativityScore(data.creativity_score);
        setEvents(prev => [...prev, ...data.events]);
    });
```

---

## Comptes de test (après seed)
| Email | Mot de passe | Rôle |
|-------|-------------|------|
| a.kone@esp.sn | password | researcher |
| a.mbaye@esp.sn | password | engineer |
| o.diallo@esp.sn | password | engineer |
| f.sow@esp.sn | password | engineer |
| m.ba@esp.sn | password | engineer |

---

## Prochaine étape : microservice NLP Python
Voir `../finr-nlp/` — FastAPI + transformers pour la classification du raisonnement.
