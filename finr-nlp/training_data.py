"""
training_data.py
Corpus d'entraînement annoté pour la classification du raisonnement en STEAM.
Chaque exemple est un extrait de notes d'ingénieur avec son label de raisonnement.
"""

TRAINING_EXAMPLES = [
    # ── Analytique ──────────────────────────────────────────────────────────
    ("Je décompose le problème en trois contraintes principales : charge, matériau, coût.", "Analytique"),
    ("La pression exercée par le vent est calculée selon P = 0.5 × ρ × v². Pour v=120km/h, P ≈ 240 Pa.", "Analytique"),
    ("Étape 1 : identifier les forces. Étape 2 : calculer les moments. Étape 3 : vérifier la résistance.", "Analytique"),
    ("J'analyse les données de résistance : acier 400 MPa, aluminium 270 MPa, rapport résistance/poids favorable à l'aluminium.", "Analytique"),
    ("Contrainte 1 : poids maximal 2 kg. Contrainte 2 : résistance 500 N. Contrainte 3 : budget 10 000 FCFA.", "Analytique"),
    ("Le modèle mathématique donne : F = m × a, avec m = 5 kg et a = 9.81 m/s², donc F = 49 N.", "Analytique"),
    ("Je liste les paramètres : température ambiante 35°C, humidité 80%, durée de vie minimale 15 ans.", "Analytique"),
    ("Analyse des défaillances possibles : corrosion (probabilité haute), fatigue (moyenne), rupture (faible).", "Analytique"),
    ("J'identifie 4 sous-problèmes indépendants que je résoudrai séquentiellement.", "Analytique"),
    ("Les données montrent une corrélation forte entre l'épaisseur et la résistance : r = 0.94.", "Analytique"),
    ("Je structure ma démarche : d'abord les contraintes physiques, ensuite les contraintes économiques.", "Analytique"),
    ("Calcul de la section minimale : section = F / (σ_max) = 500 / 200 = 2.5 cm².", "Analytique"),
    ("La décomposition fonctionnelle donne : fonction principale + 3 fonctions contraintes.", "Analytique"),
    ("Je vérifie les unités : Newton × mètre = Joule. Le bilan énergétique est cohérent.", "Analytique"),
    ("Tableau comparatif des matériaux : acier (lourd, résistant), alu (léger, coûteux), composite (optimal).", "Analytique"),

    # ── Créatif ─────────────────────────────────────────────────────────────
    ("Et si on utilisait des sachets plastiques recyclés comme isolant ? C'est abondant ici.", "Créatif"),
    ("Idée folle : imprimer les pièces en 3D avec du PET recyclé des bouteilles locales.", "Créatif"),
    ("On pourrait combiner deux approches totalement différentes pour obtenir quelque chose de nouveau.", "Créatif"),
    ("Je visualise une structure en nid d'abeilles — légère, résistante et fabricable localement.", "Créatif"),
    ("Pourquoi ne pas transformer cette contrainte en avantage ? La chaleur pourrait alimenter le système.", "Créatif"),
    ("J'imagine un mécanisme auto-ajustable qui s'adapte à la dilatation thermique sans vis.", "Créatif"),
    ("Solution non conventionnelle : remplacer le métal par du bambou traité thermiquement.", "Créatif"),
    ("Et si on inversait le problème ? Au lieu de résister au vent, on l'utilise pour stabiliser.", "Créatif"),
    ("Idée : système modulaire comme des Lego, chaque pièce remplaçable sans outil.", "Créatif"),
    ("Je pense à un design inspiré des termitières — auto-régulation thermique naturelle.", "Créatif"),
    ("On pourrait crowdsourcer la fabrication aux artisans locaux avec un kit open-source.", "Créatif"),
    ("Et si la structure elle-même devenait un capteur ? Intégrer les jauges de déformation.", "Créatif"),
    ("Idée disruptive : abandonner la fixation rigide au profit d'un système flottant amorti.", "Créatif"),
    ("Je remets en question le cahier des charges — la contrainte des 120 km/h est peut-être surestimée.", "Créatif"),
    ("Conception biomimétique : s'inspirer des crampons des moules marines pour l'adhérence.", "Créatif"),

    # ── Par analogie ────────────────────────────────────────────────────────
    ("C'est exactement le même principe que les fixations utilisées en alpinisme.", "Par analogie"),
    ("Ce problème ressemble à ce qu'on résout dans l'aéronautique pour fixer les panneaux de fuselage.", "Par analogie"),
    ("J'ai vu une solution similaire dans la construction navale — des brides de serrage à came.", "Par analogie"),
    ("C'est comme le système racinaire des baobabs : ancrage profond, surface large.", "Par analogie"),
    ("Analogie avec les ponts suspendus : répartir les charges sur plusieurs points d'ancrage.", "Par analogie"),
    ("Le même principe que les velcros — fixation par micro-crochets, démontable sans outil.", "Par analogie"),
    ("En biologie, les os longs ont exactement cette structure creuse : résistants et légers.", "Par analogie"),
    ("Je m'inspire du design des paraboles satellitaires — même contrainte vent, même environnement tropical.", "Par analogie"),
    ("C'est le principe des ressorts de suspension automobile : absorber les chocs plutôt que résister.", "Par analogie"),
    ("Analogie avec les cages de Faraday — enveloppe conductrice qui redistribue les contraintes.", "Par analogie"),
    ("Comme les joints de dilatation dans les rails de chemin de fer — permettre le mouvement contrôlé.", "Par analogie"),
    ("Ce système ressemble aux fixations de ski : libération contrôlée en cas de surcharge.", "Par analogie"),
    ("Je transpose la solution des panneaux publicitaires sur autoroute — conçus pour 150 km/h.", "Par analogie"),
    ("Même logique que les échafaudages : modulaire, réutilisable, résistant.", "Par analogie"),
    ("Analogie avec les systèmes d'attache des satellites : tolérance aux vibrations extrêmes.", "Par analogie"),

    # ── Essai-erreur ────────────────────────────────────────────────────────
    ("J'essaie avec 4 vis M8, ça ne tient pas. Je passe à M10.", "Essai-erreur"),
    ("Première tentative : bride simple. Échec — glissement latéral. Deuxième tentative : bride avec cale.", "Essai-erreur"),
    ("J'ai testé 3 configurations. Aucune n'est satisfaisante. Je recommence avec un angle différent.", "Essai-erreur"),
    ("L'acier inox ne fonctionne pas ici — trop lourd. Je teste l'aluminium 6061.", "Essai-erreur"),
    ("Itération 1 : épaisseur 2mm. Trop flexible. Itération 2 : 3mm. Toujours insuffisant. Itération 3 : 4mm. OK.", "Essai-erreur"),
    ("Je tente une approche empirique : tester plusieurs espacements et mesurer la résistance.", "Essai-erreur"),
    ("Erreur dans mon calcul précédent — j'avais oublié le facteur de sécurité. Je reprends.", "Essai-erreur"),
    ("Ça ne marche pas avec ce matériau. J'essaie une autre combinaison.", "Essai-erreur"),
    ("Troisième essai de disposition des ancrages. La précédente créait des contraintes excessives.", "Essai-erreur"),
    ("Je reviens en arrière sur mon choix — l'aluminium coûte trop cher. Retour à l'acier galvanisé.", "Essai-erreur"),
    ("Hypothèse testée et réfutée : le joint d'étanchéité seul ne suffit pas à éviter la corrosion.", "Essai-erreur"),
    ("Après 4 prototypes, je commence à comprendre où se trouvent les zones de faiblesse.", "Essai-erreur"),
    ("J'abandonne la solution à vis au profit d'un serrage par écrou borgne — moins de risque de desserrage.", "Essai-erreur"),
    ("Test de la solution n°2 : rupture à 89 N au lieu des 120 N requis. Il faut renforcer.", "Essai-erreur"),
    ("Je reprends depuis le début avec une approche différente — trop d'itérations infructueuses.", "Essai-erreur"),

    # ── Systémique ──────────────────────────────────────────────────────────
    ("Je modélise l'ensemble du système : panneau + fixation + tôle + structure porteuse comme un tout.", "Systémique"),
    ("Il faut considérer l'impact sur la toiture : une fixation trop rigide transmet les vibrations.", "Systémique"),
    ("Le système doit fonctionner en interaction avec l'environnement : chaleur, humidité, vent, UV.", "Systémique"),
    ("Je cartographie les flux : flux d'énergie, flux de forces, flux thermiques dans l'ensemble.", "Systémique"),
    ("Une modification ici aura des effets sur trois autres composants — il faut penser globalement.", "Systémique"),
    ("Le cycle de vie complet : fabrication, installation, maintenance, démontage, recyclage.", "Systémique"),
    ("Je modélise les interactions entre les acteurs : installateur, utilisateur, mainteneur.", "Systémique"),
    ("Analyse des effets de bord : si je renforce la fixation, la tôle devient le maillon faible.", "Systémique"),
    ("Le système socio-technique : technique efficace mais adoptable par des techniciens locaux.", "Systémique"),
    ("Vision globale : l'optimisation locale d'une pièce peut dégrader les performances globales.", "Systémique"),
    ("Je trace la cartographie des risques sur tout le système — pas seulement la fixation.", "Systémique"),
    ("Interdépendances : la dilatation thermique affecte la fixation qui affecte l'étanchéité.", "Systémique"),
    ("Approche systémique : le problème n'est pas la fixation mais l'interface fixation-tôle-panneau.", "Systémique"),
    ("Je modélise le comportement dynamique du système complet sous charge de vent.", "Systémique"),
    ("Pensée systémique : la solution doit être robuste aux variations de l'environnement sur 20 ans.", "Systémique"),
]

# Reasoning types
LABELS = ["Analytique", "Créatif", "Par analogie", "Essai-erreur", "Systémique"]
