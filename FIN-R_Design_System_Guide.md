# FIN-R - Guide de Conception pour Figma

## 🎨 Design System

### Couleurs Principales
```
Primaire (Violet):
- Primary: #7C3AED (var(--purple))
- Primary Dark: #5B21B6 (var(--purple-dark))
- Primary Light: #EDE9FE (var(--purple-light))

Succès (Vert):
- Success: #10B981 (var(--green))
- Success Mid: #059669 (var(--green-mid))
- Success BG: #D1FAE5 (var(--green-bg))

Attention (Amber):
- Warning: #F59E0B (var(--amber))
- Warning Mid: #D97706 (var(--amber-mid))
- Warning BG: #FEF3C7 (var(--amber-bg))

Erreur (Rouge):
- Error: #EF4444 (var(--red))
- Error Mid: #DC2626 (var(--red-mid))
- Error BG: #FEE2E2 (var(--red-bg))

Neutres:
- Dark: #1E293B (var(--dark))
- Gray: #64748B (var(--gray))
- Gray Light: #94A3B8 (var(--gray-light))
- Border: #E2E8F0 (var(--border))
- Background: #F8FAFC (var(--light-bg))
```

### Typographie
```
Font Family: Inter (ou system-ui)
- H1: 24px, weight 800
- H2: 20px, weight 800
- H3: 18px, weight 700
- Body: 14px, weight 400
- Small: 12px, weight 500
- Caption: 11px, weight 700, uppercase, letter-spacing 0.5px
```

### Espacement
```
Radius: 8px (var(--radius))
Padding standard: 16px - 24px
Gap standard: 8px, 12px, 16px, 20px
```

## 📱 Pages à Créer dans Figma

### 1. Login Page
**Layout:**
- Centré verticalement et horizontalement
- Carte blanche avec ombre
- Logo FIN-R en haut (icône FlaskConical + texte)
- Boutons de connexion par rôle
- Bouton "Accès démo rapide"

**Éléments:**
- Titre: "Connexion"
- Sous-titre: "Plateforme de détection du raisonnement"
- 2 boutons principaux: "Chercheur" et "Ingénieur"
- 4 boutons démo: A.Kone, A.Mbaye, O.Diallo, F.Sow, M.Ba
- Footer: "ESP/UCAD - Dakar, Sénégal"

**Couleurs:**
- Background: gradient violet (#EEF2FF → #E0E7FF)
- Boutons: gradient violet
- Texte: blanc sur violet

---

### 2. Dashboard (Chercheur)
**Layout:**
- Sidebar gauche (260px) - navigation
- Contenu principal (flex: 1)
- Header avec titre + bouton "Nouvelle session"

**Structure:**
```
┌─────────────────────────────────────────┐
│ Sidebar │ Header: Vue d'ensemble        │
│         │ [Nouvelle session]            │
│ Logo    │                               │
│ Nav     │ ┌──────┬──────┬──────┐       │
│ Items   │ │Card 1│Card 2│Card 3│       │
│         │ └──────┴──────┴──────┘       │
│         │                               │
│         │ ┌────────┬────────┬────────┐ │
│         │ │Session │Reasoning│Monthly │ │
│         │ │ List   │  Bars  │ Chart  │ │
│         │ └────────┴────────┴────────┘ │
│         │                               │
│         │ ┌───────────────────────────┐ │
│         │ │ Engineers Table           │ │
│         │ └───────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Cards Métriques (4):**
1. Sessions totales (violet)
2. Ingénieurs suivis (bleu)
3. Raisonnement dominant (amber)
4. Score créativité moy. (vert)

**Dimensions:**
- Card: hauteur ~100px, padding 20px
- Border radius: 14px
- Shadow: var(--shadow-lg)

---

### 3. Workspace (Ingénieur)
**Layout:**
- Top bar fixe (72px)
- Éditeur principal (gauche, flex: 1)
- Panel d'analyse (droite, 320px)

**Top Bar:**
```
┌──────────────────────────────────────────────────┐
│ [Logo] FIN-R │ Session #1 │ [Durée] │ [Boutons] │
└──────────────────────────────────────────────────┘
```

**Éditeur:**
- Header gradient violet avec message de bienvenue
- Banner problème (jaune/amber)
- Tabs: Notes | Schéma | Étapes | Idées
- Zone de texte principale
- Bouton "Vocal" (micro) en haut à droite

**Panel Analyse (droite):**
- Status: "Analyse en cours" (vert) / "En attente" (gris)
- ReasoningBars: barres de progression
- Score créativité (grand chiffre)
- Événements captés (liste)
- Ressources (liens)

**Couleurs:**
- Background: gradient subtil (#EEF2FF → #F8FAFC)
- Cards: blanc avec blur effect
- Boutons: gradients colorés

---

### 4. Reasoning Page
**Layout:**
- Header: "Raisonnements" + sous-titre
- 3 boutons pills: Formel | Informel | Non formel
- Grid 2 colonnes

**Contenu:**
```
┌──────────────────────────────────────┐
│ [Formel] [Informel] [Non formel]     │
├──────────────────────────────────────┤
│ Description du pilier (pleine largeur)│
├────────────────────┬─────────────────┤
│ Statistiques       │ Sessions        │
│ - X sessions       │ associées       │
│ - Créativité moy.  │ (liste)         │
│ - Présence moy.    │                 │
├────────────────────┴─────────────────┤
│ Présence du pilier dans chaque session│
│ (barres de progression)              │
└──────────────────────────────────────┘
```

**Piliers:**
- **Formel** (violet #7F77DD):
  - Logical: inferential, analytical, rule-based
  - Derives conclusions from fixed and known sets of premises
  - Linear, cartesian, systemic thinking
  - Well-defined, well-structured problems
  
- **Informel** (orange #EF9F27):
  - Illogical: informal, empirical, implicit, inferential intuition
  - Derive conclusions based on prior experience and beliefs
  - Non-linear, experiential thinking
  - Ill-defined, ill-structured, and open-ended problems
  
- **Non formel** (vert #1D9E75):
  - Alogical, non-logical: neither logical nor illogical
  - Non-inferential, unregulated, highly tacit, holistic intuition
  - Derives conclusions from unknown and unfixed premises
  - Non-linear, unexpected, unpredicted thinking

---

### 5. Stats Page
**Layout:**
- Header: "Statistiques"
- Grid 2x2 de cartes

**Graphiques:**
1. **Bar Chart** - Répartition par piliers (3 barres)
2. **Radar Chart** - Profil cognitif moyen (3 axes)
3. **Line Chart** - Score créativité par session
4. **Bar Chart horizontal** - Types d'événements

**Tableau en bas:**
- Colonnes: Ingénieur | Durée | Créativité | Raisonnement dominant | Événements
- Lignes: une par session

---

### 6. Session Detail
**Layout:**
- Bouton retour
- Header: Avatar + Nom + Date + Pill raisonnement
- KPIs: 3 cards (Créativité, Événements, Durée)
- Grid 2x2:
  - ReasoningBars (détail par type)
  - Radar chart (3 piliers)
  - Notes de l'ingénieur
  - Événements captés

---

### 7. Engineers Page
**Layout:**
- Header: "Ingénieurs" + bouton "Ajouter"
- Search bar
- Grid de cards (responsive)

**Card Ingénieur:**
```
┌─────────────────────────┐
│ [Avatar] Nom        [X] │
│          Spécialité     │
│ 📧 email                │
│ 🧠 Raisonnement dominant│
├─────────────────────────┤
│ Sessions: 7  │ Créativité│
│              │ moy: 6.4  │
└─────────────────────────┘
```

---

### 8. Sessions Page
**Layout:**
- Header: "Sessions" + bouton "Nouvelle session"
- Search bar
- Liste de cards verticales

**Card Session:**
```
┌──────────────────────────────────────┐
│ [Avatar] Nom    [Status] [Pill]      │
│ Problème de conception...            │
│ 🕐 Date · Durée  ⭐ Créativité      │
│                              [Supprimer]│
└──────────────────────────────────────┘
```

---

## 🧩 Composants Réutilisables

### Buttons
**Primary:**
- Background: gradient violet
- Text: blanc
- Padding: 10px 18px
- Radius: 8px
- Shadow: 0 2px 8px rgba(83,74,183,0.3)

**Secondary:**
- Background: blanc
- Border: 2px solid couleur
- Text: couleur
- Padding: 8px 16px

**Danger:**
- Background: gradient rouge
- Text: blanc

### Cards
- Background: rgba(255,255,255,0.95)
- Border: 1px solid var(--border)
- Radius: 14px
- Shadow: var(--shadow-lg)
- Padding: 20-24px

### Pills (Badges)
- Background: couleur + 20% opacity
- Text: couleur
- Padding: 4px 12px
- Radius: 20px
- Font: 12px, weight 600

### Inputs
- Border: 1px solid var(--border)
- Radius: 8px
- Padding: 10px 14px
- Font: 14px
- Focus: border violet

## 📐 Grille et Layout

**Container:**
- Max-width: 1400px
- Padding: 28px
- Gap: 20px

**Sidebar:**
- Width: 260px
- Background: blanc
- Border-right: 1px solid var(--border)

**Grid Systems:**
- 3 colonnes: 1fr 1fr 1fr
- 2 colonnes: 1fr 1fr
- Cards: repeat(auto-fill, minmax(280px, 1fr))

## 🎯 États et Interactions

### États des Boutons
- Default
- Hover: elevation +2px, shadow augmentée
- Active: transform translateY(-1px)
- Disabled: opacity 0.5

### États des Cards
- Default
- Hover: shadow-xl, transform translateY(-3px)

### Animations
- Transitions: 0.2s - 0.3s
- Keyframes: pulse pour enregistrement
- Loading: spinner CSS

## 📱 Responsive Breakpoints

- Desktop: > 1024px (layout complet)
- Tablet: 768px - 1024px (sidebar collapsible)
- Mobile: < 768px (stack vertical)

## 🎨 Assets et Icônes

**Librairie:** Lucide React
- Icônes utilisées: Mic, MicOff, PlayCircle, Square, PlusCircle, Search, Trash2, etc.

**Logo:**
- Icône: FlaskConical (ou laboratoire)
- Texte: "FIN-R" en bold, violet
- Subtitle: "ESP/UCAD"

## 📋 Checklist pour Figma

- [ ] Créer le Design System (couleurs, typographie, composants)
- [ ] Créer les variants de boutons
- [ ] Créer les variants de cards
- [ ] Créer les variants de inputs
- [ ] Créer les pages: Login, Dashboard, Workspace, Reasoning, Stats, Sessions, Engineers
- [ ] Créer les états: Default, Hover, Active, Loading
- [ ] Créer les variants responsive
- [ ] Ajouter les interactions (prototype)
- [ ] Exporter les assets (icônes, images)

## 💡 Conseils pour Figma

1. **Utiliser Auto Layout** pour tous les composants
2. **Créer des Components** pour les éléments réutilisables
3. **Utiliser des Variants** pour les états
4. **Créer des Styles** pour couleurs et typographie
5. **Organiser en Pages** : Design System, Desktop, Mobile
6. **Ajouter des Prototypes** pour les interactions clés
7. **Utiliser des Plugins** : Figma to Code, Autoflow, etc.

## 🚀 Prochaines Étapes

1. Ouvrir Figma
2. Créer un nouveau fichier "FIN-R Design System"
3. Importer les couleurs et typographie
4. Créer les composants de base
5. Assembler les pages
6. Tester le prototype
7. Partager avec l'équipe

---

**Note:** Ce guide est basé sur l'implémentation React actuelle. Toutes les dimensions, couleurs et espacements sont extraits du code source.