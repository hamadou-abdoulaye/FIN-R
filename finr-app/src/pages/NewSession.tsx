import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useEngineers } from '../hooks/useEngineers';
import { useSessions } from '../hooks/useSessions';
import { useAuth } from '../context/AuthContext';
import { ArrowLeft, PlayCircle, Loader } from 'lucide-react';

const NewSession: React.FC = () => {
  const navigate = useNavigate();
  const { engineers, isLoading: loadingEng } = useEngineers();
  const { createSession } = useSessions();
  const { user } = useAuth();
  const [form, setForm] = useState({ engineerId: '', problem: '', notes: '' });
  const [error, setError] = useState('');
  const [saving, setSaving] = useState(false);

  const handleStart = async () => {
    if (!form.engineerId || !form.problem.trim()) { setError('Veuillez sélectionner un ingénieur et saisir un problème.'); return; }
    setSaving(true); setError('');
    try {
      const session = await createSession(form.engineerId, form.problem);
      // Redirection selon le rôle : chercheur → détail session, ingénieur → workspace
      if (user?.role === 'engineer') {
        navigate(`/workspace/${session.id}`);
      } else {
        navigate(`/sessions/${session.id}`);
      }
    } catch (e: any) {
      setError(e.response?.data?.message || 'Erreur lors de la création.');
      setSaving(false);
    }
  };

  return (
    <div style={{ maxWidth: 640, margin: '0 auto' }}>
      <button onClick={() => navigate('/sessions')} style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'var(--gray)', fontSize: 14, marginBottom: 24 }}>
        <ArrowLeft size={14} /> Retour
      </button>
      <h1 style={{ fontSize: 24, fontWeight: 800, color: 'var(--dark)', marginBottom: 6 }}>Nouvelle session</h1>
      <p style={{ fontSize: 14, color: 'var(--gray)', marginBottom: 28 }}>Configurez la session avant de démarrer l'enregistrement.</p>

      <div style={{ background: 'rgba(255,255,255,0.92)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)', padding: 28, display: 'flex', flexDirection: 'column', gap: 20 }}>
        <div>
          <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 8 }}>Ingénieur *</label>
          {loadingEng
            ? <div style={{ color: 'var(--gray)', fontSize: 13 }}>Chargement...</div>
            : <select value={form.engineerId} onChange={e => setForm(f => ({ ...f, engineerId: e.target.value }))}
                style={{ width: '100%', padding: '10px 12px', border: '1px solid var(--border)', borderRadius: 8, fontSize: 14, background: 'white', outline: 'none' }}>
                <option value="">Sélectionner un ingénieur...</option>
                {engineers.map(e => <option key={e.id} value={e.id}>{e.name} — {e.specialty}</option>)}
              </select>
          }
        </div>

        <div>
          <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 8 }}>Problème de conception *</label>
          <textarea value={form.problem} onChange={e => setForm(f => ({ ...f, problem: e.target.value }))} rows={5}
            placeholder="Décrivez le problème soumis à l'ingénieur. Soyez précis sur les contraintes et objectifs."
            style={{ width: '100%', padding: '10px 12px', border: '1px solid var(--border)', borderRadius: 8, fontSize: 14, lineHeight: 1.6, resize: 'vertical', outline: 'none' }} />
        </div>

        <div>
          <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 8 }}>Notes du chercheur <span style={{ fontWeight: 400, color: 'var(--gray)' }}>(optionnel)</span></label>
          <textarea value={form.notes} onChange={e => setForm(f => ({ ...f, notes: e.target.value }))} rows={3}
            placeholder="Hypothèses, contexte expérimental..."
            style={{ width: '100%', padding: '10px 12px', border: '1px solid var(--border)', borderRadius: 8, fontSize: 14, lineHeight: 1.6, resize: 'vertical', outline: 'none' }} />
        </div>

        {error && <div style={{ background: 'var(--red-bg)', color: 'var(--red)', borderRadius: 8, padding: '10px 14px', fontSize: 13 }}>{error}</div>}

        <div style={{ display: 'flex', gap: 12, justifyContent: 'flex-end' }}>
          <button onClick={() => navigate('/sessions')} style={{ padding: '10px 20px', borderRadius: 8, fontSize: 14, fontWeight: 600, color: 'var(--gray)', border: '1px solid var(--border)', background: 'white' }}>
            Annuler
          </button>
          <button onClick={handleStart} disabled={saving} style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--green-mid)', color: 'white', padding: '10px 22px', borderRadius: 8, fontWeight: 600, fontSize: 14, opacity: saving ? 0.7 : 1 }}>
            {saving ? <><Loader size={15} style={{ animation: 'spin 1s linear infinite' }} /> Création...</> : <><PlayCircle size={16} /> Démarrer</>}
          </button>
        </div>
      </div>
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );
};

export default NewSession;

