import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSessions } from '../hooks/useSessions';
import { Avatar, ReasoningPill } from '../components/shared/Pill';
import { ReasoningType } from '../types';
import { PlusCircle, Search, Clock, Star, Trash2 } from 'lucide-react';
import ConfirmDialog from '../components/ConfirmDialog';
import { CardSkeleton } from '../components/Skeleton';

const Sessions: React.FC = () => {
  const navigate = useNavigate();
  const { sessions, isLoading, error, deleteSession } = useSessions();
  const [search, setSearch] = useState('');
  const [deleteId, setDeleteId] = useState<string | number | null>(null);

  const filtered = sessions.filter(s =>
    s.engineerName?.toLowerCase().includes(search.toLowerCase()) ||
    s.engineer_name?.toLowerCase().includes(search.toLowerCase()) ||
    s.problem?.toLowerCase().includes(search.toLowerCase())
  );

  const handleDelete = async () => {
    if (!deleteId) return;
    try {
      await deleteSession(String(deleteId));
    } catch (e) {
      console.error('Erreur suppression:', e);
    } finally {
      setDeleteId(null);
    }
  };

  const statusColors: Record<string, string> = {
    completed: 'var(--green-mid)', active: 'var(--purple)', paused: 'var(--amber-mid)', draft: 'var(--gray)',
  };
  const statusLabels: Record<string, string> = {
    completed: 'Terminée', active: 'En cours', paused: 'En pause', draft: 'Brouillon',
  };

  if (isLoading) return (
    <div>
      <div style={{ height: 60, marginBottom: 20, background: 'rgba(255,255,255,0.9)', borderRadius: 'var(--radius)', border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }} />
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {Array.from({ length: 4 }).map((_, i) => <CardSkeleton key={i} />)}
      </div>
    </div>
  );

  if (error) return (
    <div style={{ background: 'var(--red-bg)', color: 'var(--red)', borderRadius: 12, padding: 20, margin: 20 }}>
      ⚠ Impossible de charger les sessions : {error}
    </div>
  );

  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 28 }}>
        <div>
          <h1 style={{ fontSize: 24, fontWeight: 800, color: 'var(--dark)', marginBottom: 4 }}>Sessions</h1>
          <p style={{ fontSize: 14, color: 'var(--gray)' }}>{sessions.length} session{sessions.length > 1 ? 's' : ''} enregistrée{sessions.length > 1 ? 's' : ''}</p>
        </div>
        <button onClick={() => navigate('/sessions/new')} style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--purple)', color: 'white', padding: '10px 18px', borderRadius: 8, fontWeight: 600, fontSize: 14 }}>
          <PlusCircle size={16} /> Nouvelle session
        </button>
      </div>

      <div style={{ position: 'relative', marginBottom: 20, maxWidth: 360 }}>
        <Search size={15} style={{ position: 'absolute', left: 12, top: '50%', transform: 'translateY(-50%)', color: 'var(--gray)' }} />
        <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Chercher une session..."
          style={{ width: '100%', padding: '9px 12px 9px 36px', border: '1px solid var(--border)', borderRadius: 8, fontSize: 14, background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(8px)', outline: 'none' }} />
      </div>

      {filtered.length === 0 && (
        <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--gray)' }}>
          {search ? `Aucun résultat pour « ${search} »` : 'Aucune session. Créez-en une !'}
        </div>
      )}

      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {filtered.map(s => {
          const name = s.engineerName || s.engineer_name || '—';
          const initials = s.engineerInitials || s.engineer_initials || name.split(' ').map((w: string) => w[0]).join('').slice(0, 2).toUpperCase();
          const score = s.creativityScore ?? s.creativity_score;
          const dominant = s.dominantReasoning || s.dominant_reasoning;
          return (
            <div key={s.id} style={{ background: 'rgba(255,255,255,0.95)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)', padding: 20, transition: 'all 0.2s' }}
              onMouseEnter={e => { e.currentTarget.style.boxShadow = 'var(--shadow-xl)'; e.currentTarget.style.transform = 'translateY(-3px)'; }}
              onMouseLeave={e => { e.currentTarget.style.boxShadow = 'var(--shadow-lg)'; e.currentTarget.style.transform = 'translateY(0)'; }}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 14 }}>
                <div onClick={() => navigate(`/sessions/${s.id}`)} style={{ cursor: 'pointer', flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 4, flexWrap: 'wrap' }}>
                    <Avatar initials={initials} size={40} />
                    <div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 2 }}>
                        <span style={{ fontWeight: 700, fontSize: 15 }}>{name}</span>
                        <span style={{ fontSize: 12, color: statusColors[s.status] || 'var(--gray)', fontWeight: 600 }}>
                          ● {statusLabels[s.status] || s.status}
                        </span>
                      </div>
                      {dominant && <ReasoningPill type={dominant as ReasoningType} size="sm" />}
                    </div>
                  </div>
                  <p style={{ fontSize: 13, color: 'var(--gray)', marginBottom: 10, lineHeight: 1.5, display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                    {s.problem}
                  </p>
                  <div style={{ display: 'flex', gap: 20, fontSize: 12, color: 'var(--gray)' }}>
                    <span style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                      <Clock size={12} /> {s.date} · {s.duration || '—'}
                    </span>
                    {score != null && (
                      <span style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                        <Star size={12} /> Créativité {score}/10
                      </span>
                    )}
                    {s.events && <span>{s.events.length} événements</span>}
                  </div>
                </div>
                <button
                  onClick={(e) => { e.stopPropagation(); setDeleteId(s.id); }}
                  style={{
                    padding: '8px 12px', borderRadius: 8, fontSize: 12, fontWeight: 600,
                    background: 'var(--red-bg)', color: 'var(--red)',
                    border: '1px solid rgba(220,38,38,0.2)',
                    display: 'flex', alignItems: 'center', gap: 6,
                    transition: 'all 0.2s',
                  }}
                  onMouseEnter={e => {
                    e.currentTarget.style.background = 'var(--red-mid)';
                    e.currentTarget.style.color = 'white';
                  }}
                  onMouseLeave={e => {
                    e.currentTarget.style.background = 'var(--red-bg)';
                    e.currentTarget.style.color = 'var(--red)';
                  }}
                >
                  <Trash2 size={14} /> Supprimer
                </button>
              </div>
            </div>
          );
        })}
      </div>

      <ConfirmDialog
        isOpen={!!deleteId}
        title="Supprimer la session ?"
        message="Cette action est irréversible. La session et toutes ses données seront définitivement supprimées."
        confirmText="Supprimer"
        cancelText="Annuler"
        type="danger"
        onConfirm={handleDelete}
        onCancel={() => setDeleteId(null)}
      />
    </div>
  );
};

export default Sessions;

