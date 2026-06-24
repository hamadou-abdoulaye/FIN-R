# Makefile FIN-R
# Usage : make <cible>

.PHONY: help up down build logs shell-api shell-nlp migrate seed test-nlp reset

help:
	@echo ""
	@echo "  FIN-R — commandes disponibles"
	@echo "  ──────────────────────────────"
	@echo "  make up          Lancer tous les services"
	@echo "  make down        Arrêter tous les services"
	@echo "  make build       Rebuild les images"
	@echo "  make logs        Afficher les logs en live"
	@echo "  make migrate     Lancer les migrations Laravel"
	@echo "  make seed        Injecter les données de test"
	@echo "  make shell-api   Shell dans le container Laravel"
	@echo "  make shell-nlp   Shell dans le container NLP"
	@echo "  make test-nlp    Lancer les tests NLP"
	@echo "  make reset       Supprimer volumes + tout recréer"
	@echo ""

up:
	docker compose up -d
	@echo ""
	@echo "  ✓ FIN-R démarré"
	@echo "  → App :      http://localhost"
	@echo "  → API :      http://localhost/api"
	@echo "  → WebSocket: ws://localhost:8080"
	@echo ""

down:
	docker compose down

build:
	docker compose build --no-cache

logs:
	docker compose logs -f --tail=50

logs-api:
	docker compose logs -f api worker

logs-nlp:
	docker compose logs -f nlp

shell-api:
	docker compose exec api sh

shell-nlp:
	docker compose exec nlp sh

migrate:
	docker compose exec api php artisan migrate --force

seed:
	docker compose exec api php artisan db:seed --force

test-nlp:
	docker compose exec nlp python -m pytest tests/ -v

tinker:
	docker compose exec api php artisan tinker

reset:
	docker compose down -v
	docker compose up --build -d
