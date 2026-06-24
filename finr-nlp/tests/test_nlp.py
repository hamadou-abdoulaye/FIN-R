"""
tests/test_classifier.py
Run: python -m pytest tests/ -v
"""

import sys
sys.path.insert(0, '/home/claude/finr-nlp')

import pytest
from app.classifier import ReasoningClassifier
from app.event_detector import EventDetector


class TestReasoningClassifier:
    def setup_method(self):
        self.clf = ReasoningClassifier()

    def test_analytical_text(self):
        text = """
        La pression exercée par le vent est de 240 Pa à 120 km/h.
        Je calcule la force sur une surface de 1.5 m² : F = P × S = 360 N.
        La résistance du matériau doit être supérieure à cette valeur.
        Contrainte 1 : résistance mécanique. Contrainte 2 : coût. Contrainte 3 : durabilité.
        """
        result = self.clf.classify(text)
        assert result.dominant == 'Analytique', f"Expected Analytique, got {result.dominant}"
        assert result.scores['Analytique'] > 30

    def test_creative_text(self):
        text = """
        Et si on inventait un nouveau type de fixation ? J'ai une idée originale :
        combiner un système magnétique avec des clips innovants. Cette approche créative
        permettrait de simplifier l'installation. On pourrait aussi explorer des alternatives
        hybrides qui n'ont jamais été essayées dans ce contexte.
        """
        result = self.clf.classify(text)
        assert result.dominant in ['Créatif', 'Par analogie'], f"Got {result.dominant}"
        assert result.scores['Créatif'] > 20

    def test_analogy_text(self):
        text = """
        Ce système ressemble beaucoup à ce qu'on fait en aéronautique pour fixer les panneaux.
        En biologie, les fourmis utilisent un principe similaire pour construire leurs nids.
        On pourrait s'inspirer de cette technique et transposer le concept dans notre contexte.
        C'est analogue aux fixations utilisées dans l'industrie automobile.
        """
        result = self.clf.classify(text)
        assert result.dominant == 'Par analogie', f"Got {result.dominant}"
        assert result.scores['Par analogie'] > 30

    def test_trial_error_text(self):
        text = """
        J'ai essayé avec l'acier inoxydable mais ça ne marche pas.
        Deuxième tentative : l'aluminium anodisé. Raté aussi.
        Finalement je recommen avec un matériau composite.
        En fait, au final, je change complètement d'approche.
        Après plusieurs erreurs je reviens à la première idée.
        """
        result = self.clf.classify(text)
        assert result.dominant == 'Essai-erreur', f"Got {result.dominant}"
        assert result.scores['Essai-erreur'] > 25

    def test_systemic_text(self):
        text = """
        Il faut analyser le système global et ses interactions.
        L'impact sur l'ensemble de l'infrastructure est crucial.
        Les interdépendances entre les différents flux doivent être considérées.
        L'écosystème complet — réseau, boucles de rétroaction, effets de bord.
        """
        result = self.clf.classify(text)
        assert result.dominant == 'Systémique', f"Got {result.dominant}"

    def test_scores_sum_to_100(self):
        texts = [
            "Calcul de la résistance : F = m × a = 50 × 9.8 = 490 N",
            "Idée innovante : combiner deux systèmes pour créer quelque chose d'original",
            "Comme en aéronautique, similaire aux structures de l'Airbus A380",
        ]
        for text in texts:
            result = self.clf.classify(text)
            total = sum(result.scores.values())
            assert abs(total - 100.0) < 0.5, f"Scores sum to {total}, expected 100"

    def test_creativity_score_range(self):
        texts = [
            "1+1=2",
            "Idée très innovante et originale ! Combiner l'intelligence artificielle avec la biomimétique pour créer un système révolutionnaire.",
        ]
        for text in texts:
            result = self.clf.classify(text)
            assert 1.0 <= result.creativity_score <= 10.0

    def test_empty_text_fallback(self):
        result = self.clf.classify("   ")
        # Should return equal distribution
        for score in result.scores.values():
            assert score > 0


class TestEventDetector:
    def setup_method(self):
        self.det = EventDetector()
        self.det._cooldown = 0  # disable cooldown for tests

    def test_detects_decomposition(self):
        delta = "1. Contrainte mécanique 2. Contrainte thermique 3. Contrainte budgétaire"
        events = self.det.detect(delta, delta, session_id=1)
        types = [e.type for e in events]
        assert 'decomposition' in types

    def test_detects_analogy(self):
        delta = "C'est similaire à ce qu'on fait en aéronautique, analogue aux fourmis"
        events = self.det.detect(delta, delta, session_id=2)
        types = [e.type for e in events]
        assert 'analogy' in types

    def test_detects_insight(self):
        delta = "J'ai trouvé ! La solution est d'utiliser un système hybride !"
        events = self.det.detect(delta, delta, session_id=3)
        types = [e.type for e in events]
        assert 'insight' in types

    def test_detects_backtrack(self):
        context = "En fait finalement je change de matériau, ça ne marche pas avec l'acier"
        events = self.det.detect("en fait", context, session_id=4)
        types = [e.type for e in events]
        assert 'backtrack' in types

    def test_detects_hesitation(self):
        delta = "euh... je sais pas... peut-être ?? ou alors..."
        events = self.det.detect(delta, delta, session_id=5)
        types = [e.type for e in events]
        assert 'hesitation' in types

    def test_no_false_positive_on_neutral_text(self):
        delta = "Le métal est un matériau conducteur utilisé en industrie."
        events = self.det.detect(delta, delta, session_id=6)
        # Should detect nothing or very little
        assert len(events) <= 1

    def test_event_has_label(self):
        delta = "J'ai trouvé la solution parfaite !"
        self.det._cooldown = 0
        events = self.det.detect(delta, delta, session_id=7)
        for e in events:
            assert e.label
            assert len(e.label) > 5
