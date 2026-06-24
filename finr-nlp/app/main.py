"""
finr-nlp/app/main.py

Microservice NLP pour FIN-R.
Lance avec : uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, List, Dict
import time
import logging

from app.classifier import ReasoningClassifier
from app.event_detector import EventDetector

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("finr-nlp")

app = FastAPI(
    title="FIN-R NLP Service",
    description="Microservice d'analyse du raisonnement cognitif en STEAM",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8000", "http://localhost:3000"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Singletons (stateless classifiers, one per worker)
classifier = ReasoningClassifier()

# One detector per session (maintains cooldown state)
_detectors: Dict[int, EventDetector] = {}


def get_detector(session_id: int) -> EventDetector:
    if session_id not in _detectors:
        _detectors[session_id] = EventDetector()
    return _detectors[session_id]


# ── Schemas ──────────────────────────────────────────────────────────────────

class AnalyzeRequest(BaseModel):
    text: str = Field(..., min_length=1, description="Texte complet des notes de l'ingénieur")
    session_id: int

class AnalyzeResponse(BaseModel):
    session_id: int
    scores: Dict[str, float]       # type → percentage
    dominant: str
    creativity_score: float
    confidence: float
    processing_ms: int

class EventRequest(BaseModel):
    delta: str = Field(..., description="Nouveau texte depuis le dernier appel")
    context: str = Field(..., description="Texte complet jusqu'ici")
    session_id: int
    elapsed_seconds: int = 0

class EventItem(BaseModel):
    type: str
    label: str
    confidence: float
    metadata: dict = {}

class EventResponse(BaseModel):
    session_id: int
    events: List[EventItem]

class HealthResponse(BaseModel):
    status: str
    version: str
    classifiers_loaded: bool


# ── Endpoints ─────────────────────────────────────────────────────────────────

@app.get("/health", response_model=HealthResponse)
def health():
    return HealthResponse(
        status="ok",
        version="1.0.0",
        classifiers_loaded=True,
    )


@app.post("/analyze", response_model=AnalyzeResponse)
def analyze(req: AnalyzeRequest):
    """
    Analyse complète du texte — appelé par Laravel toutes les ~5 s pendant
    une session, ou à la fin d'une session.
    """
    if not req.text.strip():
        raise HTTPException(status_code=422, detail="Le texte est vide.")

    t0 = time.perf_counter()
    result = classifier.classify(req.text)
    elapsed_ms = int((time.perf_counter() - t0) * 1000)

    logger.info(
        f"[session={req.session_id}] dominant={result.dominant} "
        f"creativity={result.creativity_score} conf={result.confidence:.2f} "
        f"({elapsed_ms}ms)"
    )

    return AnalyzeResponse(
        session_id=req.session_id,
        scores=result.scores,
        dominant=result.dominant,
        creativity_score=result.creativity_score,
        confidence=result.confidence,
        processing_ms=elapsed_ms,
    )


@app.post("/events", response_model=EventResponse)
def detect_events(req: EventRequest):
    """
    Détection d'événements à grain fin — appelé à chaque pause de frappe
    significative (> 2 s de silence clavier).
    """
    detector = get_detector(req.session_id)
    detected = detector.detect(
        delta=req.delta,
        context=req.context,
        session_id=req.session_id,
        elapsed_seconds=req.elapsed_seconds,
    )

    events = [
        EventItem(type=e.type, label=e.label, confidence=e.confidence, metadata=e.metadata)
        for e in detected
    ]

    if events:
        logger.info(f"[session={req.session_id}] events: {[e.type for e in detected]}")

    return EventResponse(session_id=req.session_id, events=events)


@app.delete("/sessions/{session_id}")
def clear_session(session_id: int):
    """Libère l'état du détecteur quand une session se termine."""
    _detectors.pop(session_id, None)
    return {"cleared": session_id}
