export type ReasoningType = 'Analytique' | 'Créatif' | 'Par analogie' | 'Essai-erreur' | 'Systémique';

export interface Engineer {
  id: string | number;
  initials: string;
  name: string;
  email: string;
  specialty: string;
  sessionsCount?: number;
  sessions_count?: number;
  lastSession?: string;
  last_session?: string;
  dominantReasoning?: ReasoningType;
  dominant_reasoning?: string;
  avg_creativity?: number;
  averageCreativityScore?: number;
}

export interface Session {
  id: string | number;
  engineerId?: string;
  engineer_id?: string | number;
  engineerName?: string;
  engineer_name?: string;
  engineerInitials?: string;
  engineer_initials?: string;
  problem: string;
  notes?: string;
  date?: string;
  duration?: string;
  started_at?: string;
  ended_at?: string;
  status: 'active' | 'completed' | 'paused' | 'draft';
  dominantReasoning?: ReasoningType;
  dominant_reasoning?: string;
  creativityScore?: number;
  creativity_score?: number;
  reasoning?: { type: ReasoningType; pct?: number; percentage?: number }[];
  events?: SessionEvent[];
}

export interface SessionEvent {
  id: string | number;
  type: 'decomposition' | 'analogy' | 'hesitation' | 'insight' | 'backtrack';
  label: string;
  timestamp: string;
  metadata?: Record<string, any>;
}

export type UserRole = 'researcher' | 'engineer';

