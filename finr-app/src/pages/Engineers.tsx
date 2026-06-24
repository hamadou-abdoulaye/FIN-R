import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useEngineers } from '../hooks/useEngineers';
import { ReasoningType } from '../types';
import { reasoningColors } from '../data/mockData';
import { Search, PlusCircle, Mail, Brain, X, Trash2 } from 'lucide-react';
import ConfirmDialog from '../components/ConfirmDialog';
import { CardSkeleton } from '../components/Skeleton';

const Engineers: React.FC = () => {
  const navigate = useNavigate();
  const { engineers, isLoading, error, createEngineer, deleteEngineer } = useEngineers();
  const [search, setSearch] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ name: '', email: '', specialty: '', role: 'engineer' as 'engineer' | 'researcher' });
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState('');
  const [deleteId, setDeleteId] = useState<string | number | null>(null);

  const filtered = engineers.filter(e =>
    e.name?.toLowerCase().includes(search.toLowerCase()) ||
    e.specialty?.toLowerCase().includes(search.toLowerCase())
  );

  const handleCreate = async (ev: React.FormEvent) => {
    ev.preventDefault();
    if (!form.name || !form.email || !form.specialty) { setFormError('Tous les champs sont requis.'); return; }
    setSaving(true); setFormError('');
    try {
      await createEngineer(form.name, form.email, form.specialty, form.role);
      setShowForm(false); setForm({ name: '', email: '', specialty: '', role: 'engineer' });
    } catch (e: any) {
      setFormError(e.response?.data?.message || 'Erreur lors de la création.');
    } finally { setSaving(false); }
  };

  const handleDelete = async () => {
    if (!deleteId) return;
    try {
      await deleteEngineer(String(deleteId));
    } catch (e) {
      console.error('Erreur suppression:', e);
    } finally {
      setDeleteId(null);
    }
  };

  if (isLoading) return (
    <div>
      <div style={{ height: 60, marginBottom: 20, background: 'rgba(255,255,255,0.9)', borderRadius: 'var(--radius)', border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }} />
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: 16 }}>
        {Array.from({ length: 4 }).map((_, i) => <CardSkeleton key={i} />)}
      </div>
    </div>
  );

  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 28 }}>
        <div>
          <h1 style={{ fontSize: 24, fontWeight: 800, color: 'var(--dark)', marginBottom: 4 }}>Ingénieurs</h1>
          <p style={{ fontSize: 14, color: 'var(--gray)' }}>{engineers.length} ingénieur{engineers.length > 1 ? 's' : ''} suivi{engineers.length > 1 ? 's' : ''}</p>
        </div>
        <button onClick={() => setShowForm(true)} style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--purple)', color: 'white', padding: '10px 18px', borderRadius: 8, fontWeight: 600, fontSize: 14 }}>
          <PlusCircle size={16} /> Ajouter
        </button>
      </div>

      {/* Add form modal */}
      {showForm && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.4)', zIndex: 200, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <form onSubmit={handleCreate} style={{ background: 'rgba(255,255,255,0.95)', backdropFilter: 'blur(16px)', borderRadius: 16, padding: 28, width: 420, display: 'flex', flexDirection: 'column', gap: 16, border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <h2 style={{ fontSize: 18, fontWeight: 700 }}>Nouvel ingénieur</h2>
              <button type="button" onClick={() => setShowForm(false)}><X size={18} color="var(--gray)" /></button>
            </div>
            <div>
              <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6 }}>Rôle</label>
              <select value={form.role} onChange={e => setForm(f => ({ ...f, role: e.target.value as 'engineer' | 'researcher' }))}
                style={{ width: '100%', padding: '9px 12px', border: '1px solid var(--border)', borderRadius: 8, fontSize: 14, outline: 'none', background: 'white' }}>
                <option value="engineer">Ingénieur</option>
                <option value="researcher">Chercheur</option>
              </select>
            </div>
            {['name', 'email', 'specialty'].map(field => (
              <div key={field}>
                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6 }}>
                  {{ name: 'Nom complet', email: 'Email', specialty: 'Spécialité' }[field]}
                </label>
                <input type={field === 'email' ? 'email' : 'text'} required
                  value={(form as any)[field]} onChange={e => setForm(f => ({ ...f, [field]: e.target.value }))}
                  style={{ width: '100%', padding: '9px 12px', border: '1px solid var(--border)', borderRadius: 8, fontSize: 14, outline: 'none' }} />
              </div>
            ))}
            {formError && <div style={{ background: 'var(--red-bg)', color: 'var(--red)', borderRadius: 8, padding: '8px 12px', fontSize: 13 }}>{formError}</div>}
            <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end' }}>
              <button type="button" onClick={() => setShowForm(false)} style={{ padding: '9px 18px', borderRadius: 8, border: '1px solid var(--border)', fontWeight: 600, fontSize: 14 }}>Annuler</button>
              <button type="submit" disabled={saving} style={{ padding: '9px 18px', borderRadius: 8, background: 'var(--purple)', color: 'white', fontWeight: 600, fontSize: 14, opacity: saving ? 0.7 : 1 }}>
                {saving ? 'Création...' : 'Créer'}
              </button>
            </div>
          </form>
        </div>
      )}

      <div style={{ position: 'relative', marginBottom: 20, maxWidth: 360 }}>
        <Search size={15} style={{ position: 'absolute', left: 12, top: '50%', transform: 'translateY(-50%)', color: 'var(--gray)' }} />
        <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Rechercher..."
          style={{ width: '100%', padding: '9px 12px 9px 36px', border: '1px solid var(--border)', borderRadius: 8, fontSize: 14, background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(8px)', outline: 'none' }} />
      </div>

      {error && <div style={{ background: 'var(--red-bg)', color: 'var(--red)', borderRadius: 8, padding: '10px 14px', fontSize: 13, marginBottom: 16 }}>⚠ {error}</div>}

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: 16 }}>
        {filtered.map(eng => {
          const col = reasoningColors[(eng.dominant_reasoning || eng.dominantReasoning) as ReasoningType] || 'var(--purple)';
          const sessCount = eng.sessions_count ?? eng.sessionsCount ?? 0;
          const avgScore = eng.avg_creativity ?? eng.averageCreativityScore ?? '—';
          const lastSess = eng.last_session ?? eng.lastSession ?? '—';
          return (
            <div key={eng.id} style={{ background: 'rgba(255,255,255,0.95)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)', padding: 20, transition: 'all 0.2s' }}
              onMouseEnter={e => { e.currentTarget.style.boxShadow = 'var(--shadow-xl)'; e.currentTarget.style.transform = 'translateY(-3px)' }}
              onMouseLeave={e => { e.currentTarget.style.boxShadow = 'var(--shadow-lg)'; e.currentTarget.style.transform = 'translateY(0)' }}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12, marginBottom: 14 }}>
                <div onClick={() => navigate(`/sessions?engineer=${eng.id}`)} style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 12, flex: 1 }}>
                  <div style={{ width: 44, height: 44, borderRadius: '50%', background: 'var(--purple-light)', color: 'var(--purple-dark)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 15, fontWeight: 700, flexShrink: 0 }}>
                    {eng.initials}
                  </div>
                  <div>
                    <div style={{ fontWeight: 700, fontSize: 15 }}>{eng.name}</div>
                    <div style={{ fontSize: 12, color: 'var(--gray)' }}>{eng.specialty}</div>
                  </div>
                </div>
                <button
                  onClick={(e) => { e.stopPropagation(); setDeleteId(eng.id); }}
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
              <div style={{ display: 'flex', flexDirection: 'column', gap: 6, marginBottom: 14 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, color: 'var(--gray)' }}><Mail size={12} /> {eng.email}</div>
                {(eng.dominant_reasoning || eng.dominantReasoning) && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, color: 'var(--gray)' }}>
                    <Brain size={12} />
                    <span style={{ color: col, fontWeight: 600 }}>{eng.dominant_reasoning || eng.dominantReasoning}</span>
                  </div>
                )}
              </div>
              <div style={{ borderTop: '1px solid var(--border)', paddingTop: 12, display: 'flex', justifyContent: 'space-between' }}>
                <div style={{ textAlign: 'center' }}>
                  <div style={{ fontSize: 18, fontWeight: 800, color: 'var(--dark)' }}>{sessCount}</div>
                  <div style={{ fontSize: 11, color: 'var(--gray)' }}>Sessions</div>
                </div>
                <div style={{ textAlign: 'center' }}>
                  <div style={{ fontSize: 18, fontWeight: 800, color: 'var(--purple)' }}>{avgScore !== '—' ? `${avgScore}` : '—'}</div>
                  <div style={{ fontSize: 11, color: 'var(--gray)' }}>Créativité moy.</div>
                </div>
                <div style={{ textAlign: 'center' }}>
                  <div style={{ fontSize: 12, fontWeight: 600, color: 'var(--gray-light)' }}>{lastSess}</div>
                  <div style={{ fontSize: 11, color: 'var(--gray)' }}>Dernière session</div>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      <ConfirmDialog
        isOpen={!!deleteId}
        title="Supprimer l'ingénieur ?"
        message="Cette action est irréversible. L'ingénieur et toutes ses sessions seront supprimés."
        confirmText="Supprimer"
        cancelText="Annuler"
        type="danger"
        onConfirm={handleDelete}
        onCancel={() => setDeleteId(null)}
      />
    </div>
  );
};

export default Engineers;

