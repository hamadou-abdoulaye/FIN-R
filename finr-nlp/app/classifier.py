"""
finr-nlp/app/classifier.py

Classifieur de raisonnement hybride :
  1. Lexique pondéré par type de raisonnement (règles expertes)
  2. Score TF-IDF sur les n-grams caractéristiques
  3. Combinaison linéaire → distribution de probabilité sur 5 types

En production : remplacer par un modèle CamemBERT fine-tuné sur des
transcriptions d'ingénieurs annotées manuellement.
"""

import re
import math
from dataclasses import dataclass, field
from typing import Dict, List, Tuple

# ── Lexique expert ──────────────────────────────────────────────────────────
# Chaque entrée : (motif regex, type, poids)
LEXICON: List[Tuple[str, str, float]] = [
    # Analytique
    (r'\b(analys|décompos|contrainte|calcul|équation|formule|pression|force|résistance|charge|données|mesur|paramètre|variable|modèle mathématique|optimis)\w*', 'Analytique', 1.0),
    (r'\b(donc|par conséquent|en effet|vérifi|démontr|prouve|résulte|implique|déduire|induire)\w*', 'Analytique', 0.7),
    (r'\b\d+[\.,]\d+\s*(pa|mpa|kn|kg|m²|km\/h|fcfa|%)', 'Analytique', 1.2),

    # Créatif
    (r'\b(idée|innovant|original|nouveau|créat|invent|imagin|concevoir autrement|hors du commun|révolutionnaire|brainstorm)\w*', 'Créatif', 1.0),
    (r'\b(et si|pourquoi pas|on pourrait|j\'ai une idée|alternative|explorer|tester une approche)\w*', 'Créatif', 0.8),
    (r'\b(combiner|fusionner|hybride|mixer|associer|croiser)\w*', 'Créatif', 0.9),

    # Par analogie
    (r'\b(comme|similaire|ressemble|analogue|pareil|rappelle|comparable|même principe|même logique)\w*', 'Par analogie', 0.9),
    (r'\b(dans (le domaine|le secteur|le domaine de)|en aéronautique|en biologie|en architecture|en nature|biomimét)\w*', 'Par analogie', 1.1),
    (r'\b(référence|s\'inspirer|adapter|transposer|emprunter|importer (le concept|l\'idée))\w*', 'Par analogie', 1.0),

    # Essai-erreur
    (r'\b(essai|tester|tentative|expérimenter|vérifier empiriquement|prototype|itérer|itération)\w*', 'Essai-erreur', 1.0),
    (r'\b(ça ne marche pas|erreur|échec|raté|recommen|reprendre|revenir|annuler|modifier|corriger|ajuster)\w*', 'Essai-erreur', 0.9),
    (r'\b(finalement|au final|après réflexion|en y repensant|en fait|plutôt)\w*', 'Essai-erreur', 0.6),

    # Systémique
    (r'\b(système|global|ensemble|interaction|interdépendance|flux|boucle|rétroaction|émergent|holistique)\w*', 'Systémique', 1.0),
    (r'\b(impact sur|effet de bord|conséquence sur|relation entre|lien entre|dépend de)\w*', 'Systémique', 0.9),
    (r'\b(architecture|infrastructure|réseau|écosystème|chaîne)\w*', 'Systémique', 0.7),
]

REASONING_TYPES = ['Analytique', 'Créatif', 'Par analogie', 'Essai-erreur', 'Systémique']


@dataclass
class ClassificationResult:
    scores: Dict[str, float]          # type → percentage (sum = 100)
    dominant: str
    creativity_score: float            # 0–10
    confidence: float                  # 0–1


class ReasoningClassifier:
    """Classifie un texte en types de raisonnement STEAM."""

    def classify(self, text: str) -> ClassificationResult:
        text_lower = text.lower()
        raw = self._lexicon_scores(text_lower)
        raw = self._boost_with_ngrams(raw, text_lower)
        scores = self._normalize(raw)
        creativity = self._creativity_score(scores, text)
        dominant = max(scores, key=scores.get)
        confidence = scores[dominant] / 100

        return ClassificationResult(
            scores=scores,
            dominant=dominant,
            creativity_score=creativity,
            confidence=confidence,
        )

    def _lexicon_scores(self, text: str) -> Dict[str, float]:
        scores = {t: 0.0 for t in REASONING_TYPES}
        for pattern, rtype, weight in LEXICON:
            matches = re.findall(pattern, text, re.IGNORECASE)
            if matches:
                # Log-dampen to avoid single keyword dominating
                scores[rtype] += weight * (1 + math.log(len(matches)))
        return scores

    def _boost_with_ngrams(self, scores: Dict[str, float], text: str) -> Dict[str, float]:
        """Boost scores based on structural text patterns."""
        words = text.split()
        n = len(words)

        # Long text with numbers → more analytical
        num_count = len(re.findall(r'\d+[\.,]?\d*', text))
        if num_count > 3:
            scores['Analytique'] += 0.5 * num_count

        # Questions → creative or trial-error
        q_count = text.count('?')
        if q_count > 1:
            scores['Créatif'] += 0.4 * q_count
            scores['Essai-erreur'] += 0.3 * q_count

        # Long structured paragraphs → systemic
        if n > 80:
            scores['Systémique'] += 0.6

        # Comparisons with other domains → analogy
        domain_refs = re.findall(r'\b(aéronautique|biologie|médecine|agriculture|informatique|électronique|automobile|nature|fourmis|oiseaux)\b', text)
        scores['Par analogie'] += 0.8 * len(domain_refs)

        return scores

    def _normalize(self, raw: Dict[str, float]) -> Dict[str, float]:
        """Convert raw scores to percentages summing to 100."""
        total = sum(raw.values())
        if total == 0:
            # Fallback: equal distribution
            return {t: round(100 / len(REASONING_TYPES), 1) for t in REASONING_TYPES}

        # Softmax-like with temperature
        temp = 1.5
        exp_scores = {t: math.exp(v / temp) for t, v in raw.items()}
        exp_total = sum(exp_scores.values())
        pcts = {t: round((v / exp_total) * 100, 1) for t, v in exp_scores.items()}

        # Fix rounding to exactly 100
        diff = 100.0 - sum(pcts.values())
        dominant = max(pcts, key=pcts.get)
        pcts[dominant] = round(pcts[dominant] + diff, 1)

        return pcts

    def _creativity_score(self, scores: Dict[str, float], text: str) -> float:
        """
        Creativity score (0–10) based on:
        - Proportion of 'Créatif' + 'Par analogie' reasoning
        - Text diversity (unique words ratio)
        - Presence of creative markers
        """
        creative_weight = (scores.get('Créatif', 0) + scores.get('Par analogie', 0)) / 100

        words = re.findall(r'\b\w+\b', text.lower())
        diversity = len(set(words)) / max(len(words), 1) if words else 0

        creative_words = len(re.findall(
            r'\b(innovant|original|nouveau|idée|créatif|inventif|imaginatif|inédit|alternative|combiner|hybride)\w*',
            text, re.IGNORECASE
        ))
        creative_bonus = min(creative_words * 0.3, 2.0)

        score = (creative_weight * 6) + (diversity * 2) + creative_bonus
        return round(min(max(score, 1.0), 10.0), 1)
