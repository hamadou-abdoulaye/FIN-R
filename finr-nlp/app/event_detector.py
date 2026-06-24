"""
finr-nlp/app/event_detector.py

Détecte les événements cognitifs pendant une session :
  - decomposition  : l'ingénieur décompose le problème en sous-parties
  - analogy        : référence à un autre domaine
  - hesitation     : pauses longues ou corrections multiples
  - insight        : formulation soudaine d'une solution
  - backtrack      : retour en arrière sur une décision
"""

import re
import time
from dataclasses import dataclass, field
from typing import List, Optional, Dict


@dataclass
class DetectedEvent:
    type: str
    label: str
    confidence: float
    metadata: Dict = field(default_factory=dict)


# ── Patterns ────────────────────────────────────────────────────────────────

DECOMPOSITION_PATTERNS = [
    r'\b(\d+\.\s|\-\s|premièrement|deuxièmement|d\'abord|ensuite|enfin|étape \d)',
    r'\b(contrainte[s]?|paramètre[s]?|condition[s]?|critère[s]?)\s*[:\d]',
    r'\b(décompos|subdivis|séparer en|diviser en|identifier les parties)\w*',
    r'(1\.|2\.|3\.|\•|\-)\s+\w',  # list markers
]

ANALOGY_PATTERNS = [
    r'\b(comme (dans|en|pour)|similaire à|analogue à|à l\'image de|sur le modèle de)\b',
    r'\b(en (aéronautique|biologie|médecine|agriculture|informatique|électronique|automobile|nature))\b',
    r'\b(fourmis|oiseaux|termites|araignée|requin|toile|nid|écorce|os|branche)',  # biomimicry
    r'\b(s\'inspirer de|emprunter (à|le concept)|transposer|adapter depuis)\b',
    r'\b(référence|exemple de|cas similaire|même principe que)\b',
]

INSIGHT_PATTERNS = [
    r'\b(eurêka|j.ai trouvé|c.est ça|la solution est|il suffit de|on peut utiliser)\b',
    r'\b(idée[s]?\s*[:!]|solution\s*[:!]|voilà|parfait|excellent)',
    r'\b(en combinant|en fusionnant|si on utilise|avec un[e]? .{3,30} on peut)\b',
    r'(j.ai trouvé|trouvé\s*!|solution\s+est)',
]

BACKTRACK_PATTERNS = [
    r'\b(non|plutôt|en fait|finalement|au final|en y repensant|je reconsidère)\b',
    r'\b(changer|modifier|remplacer|abandonner|recommen|annuler)\w*',
    r'\b(ça ne (marche|fonctionne) pas|ce n.est pas (bon|optimal|viable))\b',
    r'\b(revenir sur|retour à|changer (de|le|la)|reconsidérer|revoir)\w*\b',
    r'\b(abandonne|laisse tomber|oublie)\b',
    r'\b(ne marche pas|pas bon|pas optimal)\b',
]

HESITATION_PATTERNS = [
    r'\b(euh|hm+|bon\.{2,}|\.{3,}|je sais pas|pas sûr|peut-être|ou alors)\b',
    r'\b(hésit|incertain|difficile à|compliqué|je ne sais pas si|dois-je)\w*',
    r'(\?\s*){2,}',  # multiple question marks
]


class EventDetector:
    """Détecte les événements cognitifs dans un delta de texte."""

    def __init__(self):
        self._last_detection_times: Dict[str, float] = {}
        self._cooldown = 30  # seconds between same event type

    def detect(
        self,
        delta: str,
        context: str,
        session_id: int,
        elapsed_seconds: int = 0,
    ) -> List[DetectedEvent]:
        """
        delta   : nouveau texte depuis le dernier appel
        context : texte complet de la session jusqu'ici
        """
        events = []
        now = time.time()
        delta_lower = delta.lower()
        context_lower = context.lower()

        checks = [
            ('decomposition', DECOMPOSITION_PATTERNS, delta_lower, 0.75),
            ('analogy',       ANALOGY_PATTERNS,       delta_lower, 0.80),
            ('insight',       INSIGHT_PATTERNS,       delta_lower, 0.85),
            ('backtrack',     BACKTRACK_PATTERNS,     context_lower[-300:], 0.70),
            ('hesitation',    HESITATION_PATTERNS,    delta_lower, 0.65),
        ]

        for event_type, patterns, text, threshold in checks:
            last = self._last_detection_times.get(event_type, 0)
            if now - last < self._cooldown:
                continue

            matched, confidence = self._match_patterns(patterns, text)
            if matched and confidence >= threshold:
                label = self._generate_label(event_type, matched, delta)
                events.append(DetectedEvent(
                    type=event_type,
                    label=label,
                    confidence=round(confidence, 2),
                    metadata={
                        'match': matched[:100],
                        'elapsed_seconds': elapsed_seconds,
                    }
                ))
                self._last_detection_times[event_type] = now

        return events

    def _match_patterns(self, patterns: List[str], text: str) -> tuple[Optional[str], float]:
        matches = []
        for pattern in patterns:
            found = re.findall(pattern, text, re.IGNORECASE)
            if found:
                matches.extend(found if isinstance(found[0], str) else [str(f) for f in found])

        if not matches:
            return None, 0.0

        # Confidence grows with number of distinct matches
        confidence = min(0.5 + len(matches) * 0.15, 0.98)
        return matches[0] if matches else None, confidence

    def _generate_label(self, event_type: str, match: str, delta: str) -> str:
        """Generate a human-readable label for the event."""
        clean = delta.strip()[:80].replace('\n', ' ')

        labels = {
            'decomposition': f'Décomposition — « {clean} »',
            'analogy':       f'Analogie détectée — « {clean} »',
            'insight':       f'Insight — « {clean} »',
            'backtrack':     f'Retour arrière — « {clean} »',
            'hesitation':    f'Hésitation détectée',
        }
        return labels.get(event_type, clean)[:120]
