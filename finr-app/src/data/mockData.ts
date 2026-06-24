import { Engineer, Session } from '../types';

export const engineers: Engineer[] = [
  { id: 'eng1', initials: 'AM', name: 'Awa Mbaye', email: 'a.mbaye@esp.sn', specialty: 'Génie mécanique', sessionsCount: 7, lastSession: "Aujourd'hui", dominantReasoning: 'Analytique' },
  { id: 'eng2', initials: 'OD', name: 'Omar Diallo', email: 'o.diallo@esp.sn', specialty: 'Génie électrique', sessionsCount: 5, lastSession: 'Hier', dominantReasoning: 'Créatif' },
  { id: 'eng3', initials: 'FS', name: 'Fatou Sow', email: 'f.sow@esp.sn', specialty: 'Génie informatique', sessionsCount: 4, lastSession: '12 juin', dominantReasoning: 'Par analogie' },
  { id: 'eng4', initials: 'MB', name: 'Moussa Bâ', email: 'm.ba@esp.sn', specialty: 'Génie civil', sessionsCount: 4, lastSession: '11 juin', dominantReasoning: 'Essai-erreur' },
  { id: 'eng5', initials: 'AS', name: 'Aïssatou Sy', email: 'a.sy@esp.sn', specialty: 'Génie industriel', sessionsCount: 4, lastSession: '10 juin', dominantReasoning: 'Systémique' },
];

export const sessions: Session[] = [
  {
    id: 'ses1', engineerId: 'eng1', engineerName: 'Awa Mbaye', engineerInitials: 'AM',
    problem: 'Concevoir un système de fixation léger pour panneaux solaires sur tôle ondulée tropicale. Résistance > 120 km/h, coût < 15 000 FCFA/unité.',
    date: "Aujourd'hui", duration: '45 min', status: 'completed', dominantReasoning: 'Analytique',
    creativityScore: 6.4,
    reasoning: [{ type: 'Analytique', pct: 72 }, { type: 'Par analogie', pct: 20 }, { type: 'Créatif', pct: 8 }],
    events: [
      { id: 'e1', type: 'decomposition', label: 'Décomposition en 3 contraintes', timestamp: '00:02:10' },
      { id: 'e2', type: 'analogy', label: 'Référence à système européen', timestamp: '00:14:35' },
      { id: 'e3', type: 'hesitation', label: 'Hésitation · retour matériau (18 s)', timestamp: '00:20:48' },
      { id: 'e4', type: 'insight', label: 'Solution hybride identifiée', timestamp: '00:38:22' },
    ],
    notes: 'Le système doit résister à des vents violents — une fixation robuste est indispensable. Contraintes identifiées :\n\n1. Charge au vent — pression ≈ 240 Pa à 120 km/h.\n2. Matériaux — inox ou aluminium anodisé (anti-corrosion).\n3. Coût — favoriser les éléments standards du marché local.',
  },
  {
    id: 'ses2', engineerId: 'eng2', engineerName: 'Omar Diallo', engineerInitials: 'OD',
    problem: 'Optimiser le rendement d\'un système d\'éclairage LED autonome pour habitat rural sans accès au réseau électrique.',
    date: 'Hier', duration: '1h10', status: 'completed', dominantReasoning: 'Créatif',
    creativityScore: 8.1,
    reasoning: [{ type: 'Créatif', pct: 55 }, { type: 'Analytique', pct: 30 }, { type: 'Systémique', pct: 15 }],
    events: [
      { id: 'e1', type: 'insight', label: 'Idée capteur de luminosité ambiante', timestamp: '00:05:20' },
      { id: 'e2', type: 'analogy', label: 'Analogie avec firefly bioluminescence', timestamp: '00:22:00' },
      { id: 'e3', type: 'backtrack', label: 'Abandon batterie NiMH → Li-ion', timestamp: '00:45:10' },
    ],
    notes: 'Explorer des solutions low-cost adaptées au marché local. Priorité à la durabilité et à la maintenabilité par des techniciens locaux.',
  },
  {
    id: 'ses3', engineerId: 'eng3', engineerName: 'Fatou Sow', engineerInitials: 'FS',
    problem: 'Concevoir un algorithme de routage pour un réseau de capteurs IoT en milieu agricole au Sénégal.',
    date: '12 juin', duration: '38 min', status: 'completed', dominantReasoning: 'Par analogie',
    creativityScore: 7.2,
    reasoning: [{ type: 'Par analogie', pct: 48 }, { type: 'Analytique', pct: 35 }, { type: 'Créatif', pct: 17 }],
    events: [
      { id: 'e1', type: 'analogy', label: 'Analogie réseau de fourmis', timestamp: '00:08:15' },
      { id: 'e2', type: 'decomposition', label: 'Décomposition topologie réseau', timestamp: '00:18:40' },
      { id: 'e3', type: 'insight', label: 'Protocole hybride AODV+énergie', timestamp: '00:31:00' },
    ],
    notes: 'Contrainte principale : autonomie des nœuds capteurs (batterie solaire). Protocole de routage doit minimiser les transmissions.',
  },
  {
    id: 'ses4', engineerId: 'eng4', engineerName: 'Moussa Bâ', engineerInitials: 'MB',
    problem: 'Calculer la résistance d\'un pont piétonnier en bois traité pour une portée de 12 m en zone humide.',
    date: '11 juin', duration: '52 min', status: 'completed', dominantReasoning: 'Essai-erreur',
    creativityScore: 5.8,
    reasoning: [{ type: 'Essai-erreur', pct: 60 }, { type: 'Analytique', pct: 32 }, { type: 'Systémique', pct: 8 }],
    events: [
      { id: 'e1', type: 'decomposition', label: 'Décomposition charges statiques/dynamiques', timestamp: '00:04:00' },
      { id: 'e2', type: 'hesitation', label: '3 tentatives section poutre', timestamp: '00:20:30' },
      { id: 'e3', type: 'backtrack', label: 'Changement essence de bois', timestamp: '00:38:55' },
    ],
    notes: 'Dimensionnement poutres maîtresses. Prise en compte des charges climatiques : humidité permanente, dilatation thermique.',
  },
];

export const reasoningColors: Record<string, string> = {
  'Analytique': '#7F77DD',
  'Créatif': '#1D9E75',
  'Par analogie': '#EF9F27',
  'Essai-erreur': '#D85A30',
  'Systémique': '#378ADD',
};

export const reasoningBgColors: Record<string, string> = {
  'Analytique': '#EEEDFE',
  'Créatif': '#E1F5EE',
  'Par analogie': '#FAEEDA',
  'Essai-erreur': '#FCEBEB',
  'Systémique': '#E8F0FD',
};

export const reasoningTextColors: Record<string, string> = {
  'Analytique': '#3C3489',
  'Créatif': '#0F6E56',
  'Par analogie': '#633806',
  'Essai-erreur': '#791F1F',
  'Systémique': '#1A4A8A',
};

