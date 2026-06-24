# FIN-R NLP Service

Microservice Python d'analyse du raisonnement cognitif.
Exposé sur `http://localhost:8001`, consommé par le backend Laravel.

## Architecture

```
Ingénieur tape dans le Workspace
        ↓ (toutes les 5 s)
Laravel PATCH /api/sessions/{id}/notes
        ↓
NlpService::analyze(text)  →  POST /analyze
        ↓
ClassificationResult { scores, dominant, creativity_score }
        ↓
Laravel broadcast(SessionUpdated)  →  WebSocket channel session.{id}
        ↓
Dashboard chercheur mis à jour en temps réel
```

## Installation

```bash
cd finr-nlp
pip install -r requirements.txt
```

## Lancer le service

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
```

Swagger UI disponible sur : http://localhost:8001/docs

## Endpoints

| Méthode | URL | Description |
|---------|-----|-------------|
| GET  | `/health` | Statut du service |
| POST | `/analyze` | Analyse complète du texte |
| POST | `/events` | Détection d'événements cognitifs |
| DELETE | `/sessions/{id}` | Libérer l'état d'une session |

### POST /analyze

```json
{
  "text": "Je calcule la pression du vent : F = P × S = 240 × 1.5 = 360 N...",
  "session_id": 1
}
```

Réponse :
```json
{
  "session_id": 1,
  "scores": {
    "Analytique": 68.2,
    "Par analogie": 15.4,
    "Créatif": 9.1,
    "Essai-erreur": 5.0,
    "Systémique": 2.3
  },
  "dominant": "Analytique",
  "creativity_score": 5.8,
  "confidence": 0.68,
  "processing_ms": 3
}
```

### POST /events

```json
{
  "delta": "J'ai trouvé ! On peut utiliser un système hybride !",
  "context": "...texte complet de la session...",
  "session_id": 1,
  "elapsed_seconds": 1423
}
```

Réponse :
```json
{
  "session_id": 1,
  "events": [
    {
      "type": "insight",
      "label": "Insight — « J'ai trouvé ! On peut utiliser un système hybride »",
      "confidence": 0.88,
      "metadata": { "elapsed_seconds": 1423 }
    }
  ]
}
```

## Tests

```bash
python -m pytest tests/ -v
# 15 passed in 0.04s
```

## Évolution vers un modèle ML

Le classifieur actuel est **hybride règles + TF-IDF**, suffisant pour un
prototype. Pour la production :

1. **Annoter** 200-500 transcriptions de sessions avec les vrais types de raisonnement
2. **Fine-tuner** CamemBERT (modèle BERT pour le français) sur ce corpus
3. **Remplacer** `ReasoningClassifier.classify()` par l'inférence du modèle
4. **Servir** avec `torch` + cache de tokenizer pour garder < 50 ms de latence

```python
# Production drop-in (dans classifier.py)
from transformers import pipeline

class ReasoningClassifier:
    def __init__(self):
        self.pipe = pipeline(
            "text-classification",
            model="./models/finr-camembert",
            top_k=5,
        )

    def classify(self, text: str) -> ClassificationResult:
        results = self.pipe(text[:512])
        scores = {r['label']: round(r['score'] * 100, 1) for r in results}
        ...
```
