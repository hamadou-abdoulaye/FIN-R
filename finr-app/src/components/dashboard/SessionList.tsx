import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Session, ReasoningType } from '../../types';
import { Avatar, ReasoningPill } from '../shared/Pill';
import { Clock } from 'lucide-react';

interface SessionListProps {
  sessions: Session[];
  limit?: number;
  title?: string;
}

const SessionList: React.FC<SessionListProps> = ({ sessions, limit, title = 'Sessions récentes' }) => {
  const navigate = useNavigate();
  const displayed = limit ? sessions.slice(0, limit) : sessions;

  return (
    <div>
      <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 12 }}>
        {title}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
        {displayed.map((s, i) => (
          <button
            key={s.id}
            onClick={() => navigate(`/sessions/${s.id}`)}
            style={{
              display: 'flex', alignItems: 'center', gap: 12,
              padding: '10px 0',
              borderBottom: i < displayed.length - 1 ? '1px solid var(--border)' : 'none',
              background: 'transparent',
              width: '100%', textAlign: 'left',
              cursor: 'pointer',
              transition: 'background 0.1s',
            }}
          >
            <Avatar initials={s.engineerInitials || s.engineer_initials || '?'} size={32} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontWeight: 600, fontSize: 13, color: 'var(--dark)', marginBottom: 2 }}>
                {s.engineerName || s.engineer_name || '—'}
              </div>
              <div style={{ fontSize: 11, color: 'var(--gray)', display: 'flex', alignItems: 'center', gap: 4 }}>
                <Clock size={10} />
                {s.date} · {s.duration}
              </div>
            </div>
            {(s.dominantReasoning || s.dominant_reasoning) && (
              <ReasoningPill type={(s.dominantReasoning || s.dominant_reasoning) as ReasoningType} size="sm" />
            )}
          </button>
        ))}
      </div>
    </div>
  );
};

export default SessionList;

