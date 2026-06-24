import React from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useSession } from '../hooks/useSession';
import { ReasoningPill } from '../components/shared/Pill';
import { Avatar } from '../components/shared/Pill';
import { ReasoningType } from '../types';
import ReasoningBars from '../components/shared/ReasoningBars';
import { RadarChart, Radar, PolarGrid, PolarAngleAxis, ResponsiveContainer, Tooltip } from 'recharts';
import { ArrowLeft, Clock, Star, Zap, ArrowRight, Loader, Eye } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

const eventColors: Record<string, string> = {
  decomposition: 'var(--purple-mid)', analogy: 'var(--amber-mid)',
  hesitation: 'var(--red-mid)', insight: 'var(--green-mid)', backtrack: 'var(--red-mid)',
};
const eventLabels: Record<string, string> = {
  decomposition: 'Décomposition', analogy: 'Analogie',
  hesitation: 'Hésitation', insight: 'Insight', backtrack: 'Retour arrière',
};

const SessionDetail: React.FC = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const { session, isLoading, error } = useSession(id);

  if (isLoading) return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: 300, gap: 10, color: 'var(--gray)' }}>
      <Loader size={18} style={{ animation: 'spin 1s linear infinite' }} /> Chargement...
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );

  if (error || !session) return (
    <div style={{ padding: 40, textAlign: 'center' }}>
      <p style={{ color: 'var(--gray)', marginBottom: 16 }}>{error || 'Session introuvable.'}</p>
      <button onClick={() => navigate('/sessions')} style={{ color: 'var(--purple)', fontWeight: 600 }}>← Retour</button>
    </div>
  );

  const name = session.engineerName || session.engineer_name || '—';
  const initials = session.engineerInitials || session.engineer_initials || name.split(' ').map((w: string) => w[0]).join('').slice(0, 2).toUpperCase();
  const score = session.creativityScore ?? session.creativity_score;
  const dominant = session.dominantReasoning || session.dominant_reasoning;
  const reasoning = session.reasoning || [];
  const events = session.events || [];

  const radarData = reasoning.map((r: any) => ({ subject: r.type, value: r.pct ?? r.percentage ?? 0 }));

  return (
    <div>
      <button onClick={() => navigate('/sessions')} style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'var(--gray)', fontSize: 14, marginBottom: 20 }}>
        <ArrowLeft size={14} /> Retour aux sessions
      </button>

      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: 24, gap: 16 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
          <Avatar initials={initials} size={48} />
          <div>
            <h1 style={{ fontSize: 22, fontWeight: 800, color: 'var(--dark)', marginBottom: 4 }}>{name}</h1>
            <div style={{ display: 'flex', gap: 12, fontSize: 13, color: 'var(--gray)', alignItems: 'center' }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: 4 }}><Clock size={13} /> {session.date} · {session.duration || '—'}</span>
              {dominant && <ReasoningPill type={dominant as ReasoningType} />}
            </div>
          </div>
        </div>
        {session.status !== 'completed' && user?.role === 'engineer' && (
          <button onClick={() => navigate(`/workspace/${session.id}`)}
            style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--green-mid)', color: 'white', padding: '10px 18px', borderRadius: 8, fontWeight: 600, fontSize: 14 }}>
            Ouvrir l'espace travail <ArrowRight size={15} />
          </button>
        )}
        {session.status !== 'completed' && user?.role === 'researcher' && (
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--purple-light)', color: 'var(--purple)', padding: '10px 18px', borderRadius: 8, fontWeight: 600, fontSize: 13, border: '1px solid #AFA9EC' }}>
            <Eye size={15} /> Observation en direct
          </div>
        )}
      </div>

      {/* Problem */}
      <div style={{ background: 'var(--purple-light)', borderRadius: 'var(--radius)', padding: '14px 18px', marginBottom: 20, border: '1px solid #AFA9EC' }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--purple)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 6 }}>Problème de conception</div>
        <p style={{ fontSize: 14, color: 'var(--purple-dark)', lineHeight: 1.6 }}>{session.problem}</p>
      </div>

      {/* KPI row */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 16, marginBottom: 20 }}>
        {[
          { icon: <Star size={20} color="var(--purple)" />, bg: 'var(--purple-light)', label: 'Score créativité', value: score != null ? `${score}/10` : '—', color: 'var(--purple)' },
          { icon: <Zap size={20} color="var(--green-mid)" />, bg: 'var(--green-bg)', label: 'Événements captés', value: String(events.length), color: 'var(--dark)' },
          { icon: <Clock size={20} color="var(--amber-mid)" />, bg: 'var(--amber-bg)', label: 'Durée', value: session.duration || '—', color: 'var(--dark)' },
        ].map(item => (
          <div key={item.label} style={{ background: 'rgba(255,255,255,0.92)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)', display: 'flex', alignItems: 'center', gap: 16 }}>
            <div style={{ width: 48, height: 48, borderRadius: 12, background: item.bg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{item.icon}</div>
            <div>
              <div style={{ fontSize: 12, color: 'var(--gray)', marginBottom: 4 }}>{item.label}</div>
              <div style={{ fontSize: 26, fontWeight: 800, color: item.color }}>{item.value}</div>
            </div>
          </div>
        ))}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
        <div style={{ background: 'rgba(255,255,255,0.92)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)' }}>
          {reasoning.length > 0
            ? <ReasoningBars data={reasoning.map((r: any) => ({ type: r.type, pct: r.pct ?? r.percentage ?? 0 }))} title="Raisonnement détecté" />
            : <p style={{ fontSize: 13, color: 'var(--gray)' }}>Pas encore de données NLP.</p>}
        </div>

        <div style={{ background: 'rgba(255,255,255,0.92)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 8 }}>Profil cognitif</div>
          {radarData.length > 0 ? (
            <ResponsiveContainer width="100%" height={200}>
              <RadarChart data={radarData}>
                <PolarGrid stroke="var(--border)" />
                <PolarAngleAxis dataKey="subject" tick={{ fontSize: 11, fill: 'var(--gray)' }} />
                <Radar name="Raisonnement" dataKey="value" stroke="var(--purple)" fill="var(--purple)" fillOpacity={0.2} />
                <Tooltip contentStyle={{ fontSize: 12, borderRadius: 8, border: '1px solid var(--border)' }} />
              </RadarChart>
            </ResponsiveContainer>
          ) : <p style={{ fontSize: 13, color: 'var(--gray)', textAlign: 'center', paddingTop: 40 }}>Données insuffisantes</p>}
        </div>

        <div style={{ background: 'rgba(255,255,255,0.92)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 12 }}>Notes de l'ingénieur</div>
          {session.notes
            ? <p style={{ fontSize: 14, color: 'var(--dark)', lineHeight: 1.7, whiteSpace: 'pre-line' }}>{session.notes}</p>
            : <p style={{ fontSize: 13, color: 'var(--gray)' }}>Aucune note.</p>}
        </div>

        <div style={{ background: 'rgba(255,255,255,0.92)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 16 }}>Événements captés</div>
          {events.length === 0
            ? <p style={{ fontSize: 13, color: 'var(--gray)' }}>Aucun événement.</p>
            : <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                {events.map((ev: any) => (
                  <div key={ev.id} style={{ display: 'flex', gap: 12, alignItems: 'flex-start' }}>
                    <div style={{ width: 10, height: 10, borderRadius: '50%', background: eventColors[ev.type] || 'var(--gray)', marginTop: 4, flexShrink: 0 }} />
                    <div>
                      <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--dark)' }}>{ev.label}</div>
                      <div style={{ fontSize: 11, color: 'var(--gray)', marginTop: 2 }}>
                        <span style={{ color: eventColors[ev.type] || 'var(--gray)', fontWeight: 600 }}>{eventLabels[ev.type] || ev.type}</span> · {ev.timestamp}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
          }
        </div>
      </div>
    </div>
  );
};

export default SessionDetail;

