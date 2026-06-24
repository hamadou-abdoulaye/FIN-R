# FIN-R - Correctif : suppression des boutons demo + vraie redirection ingenieur
# A lancer depuis le dossier finr-app avec PowerShell
$ErrorActionPreference = "Stop"
Write-Host "Application du correctif frontend..." -ForegroundColor Cyan

# ---------- src/pages/Login.tsx ----------
$file0 = @'
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../lib/api';
import { FlaskConical, Loader } from 'lucide-react';

const Login: React.FC = () => {
  const navigate = useNavigate();
  const { login } = useAuth();

  const [form, setForm] = useState({ email: '', password: '' });
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  /**
   * Redirige un ingénieur vers SA session en cours.
   * Si aucune session active n'est trouvée, on l'informe plutôt que
   * de l'envoyer vers une session qui n'est pas la sienne.
   */
  const redirectEngineer = async () => {
    try {
      const { data } = await api.get('/me/current-session');
      navigate(`/workspace/${data.id}`);
    } catch {
      setError("Aucune session en cours ne vous a été assignée. Contactez votre chercheur référent.");
      setSubmitting(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSubmitting(true);
    try {
      await login(form.email, form.password);
      const stored = localStorage.getItem('finr_user');
      const user = stored ? JSON.parse(stored) : null;
      if (user?.role === 'engineer') {
        await redirectEngineer();
      } else {
        navigate('/dashboard');
        setSubmitting(false);
      }
    } catch (err: any) {
      setError(err.message);
      setSubmitting(false);
    }
  };

  return (
    <div style={{
      minHeight: '100vh', background: 'var(--dark)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      position: 'relative', overflow: 'hidden',
    }}>
      <div style={{ position: 'absolute', top: -120, right: -80, width: 400, height: 400, borderRadius: '50%', background: 'rgba(83,74,183,0.15)' }} />
      <div style={{ position: 'absolute', bottom: -80, left: -60, width: 280, height: 280, borderRadius: '50%', background: 'rgba(83,74,183,0.10)' }} />

      <div style={{ position: 'relative', zIndex: 1, width: '100%', maxWidth: 420, padding: '0 24px' }}>
        <div style={{ textAlign: 'center', marginBottom: 36 }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 10, marginBottom: 12 }}>
            <div style={{ width: 44, height: 44, borderRadius: 12, background: 'var(--purple)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <FlaskConical size={22} color="white" />
            </div>
            <span style={{ fontSize: 36, fontWeight: 900, color: 'white', letterSpacing: -1 }}>
              FIN<span style={{ color: 'var(--purple-light)' }}>-R</span>
            </span>
          </div>
          <p style={{ color: '#B0AECF', fontSize: 14 }}>Analyse du raisonnement en STEAM · ESP/UCAD</p>
        </div>

        <form onSubmit={handleSubmit} style={{
          background: 'rgba(255,255,255,0.05)',
          border: '1px solid rgba(255,255,255,0.10)',
          borderRadius: 16, padding: 28,
          display: 'flex', flexDirection: 'column', gap: 16,
        }}>
          <div>
            <label style={{ display: 'block', fontSize: 13, color: '#B0AECF', marginBottom: 6 }}>Email</label>
            <input
              type="email" required
              value={form.email}
              onChange={e => setForm(f => ({ ...f, email: e.target.value }))}
              placeholder="vous@esp.sn"
              style={{
                width: '100%', padding: '10px 14px',
                background: 'rgba(255,255,255,0.07)',
                border: '1px solid rgba(255,255,255,0.15)',
                borderRadius: 8, color: 'white', fontSize: 14, outline: 'none',
              }}
            />
          </div>
          <div>
            <label style={{ display: 'block', fontSize: 13, color: '#B0AECF', marginBottom: 6 }}>Mot de passe</label>
            <input
              type="password" required
              value={form.password}
              onChange={e => setForm(f => ({ ...f, password: e.target.value }))}
              placeholder="••••••••"
              style={{
                width: '100%', padding: '10px 14px',
                background: 'rgba(255,255,255,0.07)',
                border: '1px solid rgba(255,255,255,0.15)',
                borderRadius: 8, color: 'white', fontSize: 14, outline: 'none',
              }}
            />
          </div>

          {error && (
            <div style={{ background: 'rgba(220,38,38,0.15)', border: '1px solid rgba(220,38,38,0.3)', borderRadius: 8, padding: '10px 14px', fontSize: 13, color: '#FCA5A5' }}>
              {error}
            </div>
          )}

          <button
            type="submit" disabled={submitting}
            style={{
              width: '100%', padding: '11px 0', borderRadius: 8,
              background: 'var(--purple)', color: 'white',
              fontWeight: 700, fontSize: 15,
              opacity: submitting ? 0.7 : 1,
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            }}
          >
            {submitting ? <><Loader size={15} style={{ animation: 'spin 1s linear infinite' }} /> Connexion...</> : 'Se connecter'}
          </button>
        </form>

        <p style={{ textAlign: 'center', fontSize: 12, color: '#5A5A7A', marginTop: 16 }}>
          ESP/UCAD · Dakar · Juin 2026
        </p>
      </div>

      <style>{`
        @keyframes spin { to { transform: rotate(360deg); } }
        input::placeholder { color: #4A4A6A; }
        input:focus { border-color: var(--purple) !important; }
      `}</style>
    </div>
  );
};

export default Login;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\pages\Login.tsx"), $file0)
Write-Host "  OK  src/pages/Login.tsx"

# ---------- src/pages/Workspace.tsx ----------
$file1 = @'
import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useSession } from '../hooks/useSession';
import ReasoningBars from '../components/shared/ReasoningBars';
import { FlaskConical, Square, RotateCcw, Lightbulb, FileText, Grid, List, Wifi, WifiOff } from 'lucide-react';
import { getEcho } from '../lib/echo';

type Tab = 'notes' | 'schema' | 'etapes' | 'idees';

const Workspace: React.FC = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { session, isLoading, saveNotes, startSession, endSession, pauseSession } = useSession(id);

  const [tab, setTab] = useState<Tab>('notes');
  const [notes, setNotes] = useState('');
  const [elapsed, setElapsed] = useState(0);
  const [running, setRunning] = useState(false);
  const [wsConnected, setWsConnected] = useState(false);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);
  const lastDeltaRef = useRef('');

  // Sync notes from session when loaded
  useEffect(() => {
    if (session?.notes) setNotes(session.notes);
    if (session?.status === 'active') setRunning(true);
  }, [session]);

  // Timer
  useEffect(() => {
    if (running) {
      intervalRef.current = setInterval(() => setElapsed(e => e + 1), 1000);
    } else {
      if (intervalRef.current) clearInterval(intervalRef.current);
    }
    return () => { if (intervalRef.current) clearInterval(intervalRef.current); };
  }, [running]);

  // WebSocket connection status
  useEffect(() => {
    if (!id) return;
    try {
      const echo = getEcho();
      echo.connector.pusher.connection.bind('connected', () => setWsConnected(true));
      echo.connector.pusher.connection.bind('disconnected', () => setWsConnected(false));
    } catch { /* demo mode — no WS */ }
  }, [id]);

  const handleNotesChange = (value: string) => {
    setNotes(value);
    // Compute delta for event detection
    const delta = value.slice(lastDeltaRef.current.length);
    lastDeltaRef.current = value;
    saveNotes(value);
  };

  const handleStart = async () => {
    try { await startSession(); } catch { /* demo */ }
    setRunning(true);
  };

  const handlePause = async () => {
    try { await pauseSession(); } catch { /* demo */ }
    setRunning(false);
  };

  const handleEnd = async () => {
    try { await endSession(); } catch { /* demo */ }
    navigate(`/sessions/${id}`);
  };

  const formatTime = (s: number) => {
    const m = Math.floor(s / 60);
    const sec = s % 60;
    return `${String(m).padStart(2, '0')}:${String(sec).padStart(2, '0')}`;
  };

  const tabs = [
    { id: 'notes' as Tab, label: 'Notes', icon: <FileText size={14} /> },
    { id: 'schema' as Tab, label: 'Schéma', icon: <Grid size={14} /> },
    { id: 'etapes' as Tab, label: 'Étapes', icon: <List size={14} /> },
    { id: 'idees' as Tab, label: 'Idées', icon: <Lightbulb size={14} /> },
  ];

  const eventDotColors: Record<string, string> = {
    decomposition: '#7F77DD', analogy: '#EF9F27',
    hesitation: '#D85A30', insight: '#1D9E75', backtrack: '#D85A30',
  };

  if (isLoading) {
    return <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--light-bg)', color: 'var(--gray)' }}>Chargement...</div>;
  }

  if (!session) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--light-bg)', flexDirection: 'column', gap: 12 }}>
        <div style={{ color: 'var(--red-mid)', fontSize: 15, fontWeight: 600 }}>Session introuvable.</div>
        <div style={{ color: 'var(--gray)', fontSize: 13 }}>Vérifiez que la session #{id} existe bien et vous est assignée.</div>
        <button onClick={() => navigate('/')} style={{ marginTop: 8, color: 'var(--purple)', fontWeight: 600, fontSize: 13 }}>← Retour à la connexion</button>
      </div>
    );
  }

  const displaySession = session;

  return (
    <div style={{ minHeight: '100vh', background: 'var(--light-bg)', display: 'flex', flexDirection: 'column' }}>
      {/* Top bar */}
      <div style={{ background: 'white', borderBottom: '1px solid var(--border)', padding: '0 24px', height: 56, display: 'flex', alignItems: 'center', gap: 16 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <FlaskConical size={18} color="var(--purple)" />
          <span style={{ fontWeight: 800, fontSize: 16, color: 'var(--purple)' }}>FIN-R</span>
        </div>
        <div style={{ width: 1, height: 20, background: 'var(--border)' }} />
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 13, color: 'var(--gray)' }}>
          <div style={{ width: 8, height: 8, borderRadius: '50%', background: running ? '#E24B4A' : '#94A3B8' }} />
          Session #{String(displaySession.id || id || '').replace('ses', '')} · {displaySession.engineerName || displaySession.engineer_name}
        </div>

        {/* WS indicator */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 11, color: wsConnected ? 'var(--green-mid)' : 'var(--gray)' }}>
          {wsConnected ? <Wifi size={12} /> : <WifiOff size={12} />}
          {wsConnected ? 'Live' : 'Hors ligne'}
        </div>

        <div style={{ flex: 1 }} />
        <div style={{ fontWeight: 700, fontSize: 15, color: 'var(--dark)', letterSpacing: 1 }}>⏱ {formatTime(elapsed)}</div>

        {!running ? (
          <button onClick={handleStart} style={{ display: 'flex', alignItems: 'center', gap: 6, background: 'var(--green-bg)', color: 'var(--green)', padding: '6px 14px', borderRadius: 6, fontWeight: 600, fontSize: 13, border: '1px solid #A7F3D0' }}>
            ▶ Démarrer
          </button>
        ) : (
          <button onClick={handlePause} style={{ display: 'flex', alignItems: 'center', gap: 6, background: '#FEF2F2', color: '#B91C1C', padding: '6px 14px', borderRadius: 6, fontWeight: 600, fontSize: 13, border: '1px solid #FECACA' }}>
            <Square size={12} /> Pause
          </button>
        )}
        <button onClick={handleEnd} style={{ background: '#E24B4A', color: 'white', padding: '6px 16px', borderRadius: 6, fontWeight: 600, fontSize: 13 }}>
          Terminer
        </button>
      </div>

      <div style={{ display: 'flex', flex: 1 }}>
        {/* Editor */}
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: 20, gap: 12 }}>
          {/* Problem banner */}
          <div style={{ background: 'var(--purple-light)', borderRadius: 10, padding: '12px 16px', border: '1px solid #AFA9EC' }}>
            <div style={{ fontSize: 10, fontWeight: 700, color: 'var(--purple)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 4 }}>Problème de conception</div>
            <p style={{ fontSize: 13, color: 'var(--purple-dark)', lineHeight: 1.5 }}>{displaySession.problem}</p>
          </div>

          {/* Tabs */}
          <div style={{ display: 'flex', gap: 8 }}>
            {tabs.map(t => (
              <button key={t.id} onClick={() => setTab(t.id)} style={{
                display: 'flex', alignItems: 'center', gap: 6,
                padding: '7px 14px', borderRadius: 6, fontSize: 13, fontWeight: tab === t.id ? 600 : 400,
                background: tab === t.id ? 'var(--purple-light)' : 'white',
                color: tab === t.id ? 'var(--purple)' : 'var(--gray)',
                border: `1px solid ${tab === t.id ? '#AFA9EC' : 'var(--border)'}`,
              }}>
                {t.icon} {t.label}
              </button>
            ))}
          </div>

          {/* Editor area */}
          <div style={{ flex: 1, background: 'white', borderRadius: 10, border: '1px solid var(--border)', padding: 16, display: 'flex', flexDirection: 'column' }}>
            {tab === 'notes' && (
              <>
                <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--dark)', marginBottom: 8 }}>Analyse du problème</div>
                <textarea
                  value={notes}
                  onChange={e => handleNotesChange(e.target.value)}
                  style={{ flex: 1, width: '100%', border: 'none', outline: 'none', resize: 'none', fontSize: 14, lineHeight: 1.7, color: 'var(--dark)', fontFamily: 'inherit', minHeight: 260 }}
                  placeholder="Commencez à noter votre analyse ici..."
                />
              </>
            )}
            {tab === 'schema' && (
              <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--gray)', flexDirection: 'column', gap: 8 }}>
                <Grid size={32} color="var(--border)" />
                <span style={{ fontSize: 13 }}>Zone de dessin — disponible bientôt</span>
              </div>
            )}
            {tab === 'etapes' && (
              <div>
                <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--dark)', marginBottom: 12 }}>Étapes de résolution</div>
                {['Analyser les contraintes', 'Identifier les matériaux', 'Calculer les forces', 'Proposer des solutions'].map((step, i) => (
                  <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 12px', background: 'var(--light-bg)', borderRadius: 8, marginBottom: 8 }}>
                    <div style={{ width: 24, height: 24, borderRadius: '50%', background: 'var(--purple-light)', color: 'var(--purple)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 12, fontWeight: 700 }}>{i + 1}</div>
                    <span style={{ fontSize: 13 }}>{step}</span>
                  </div>
                ))}
              </div>
            )}
            {tab === 'idees' && (
              <div>
                <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--dark)', marginBottom: 12 }}>Idées</div>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
                  {['Bride inox', 'Visserie M8', 'Profil aluminium', 'Joint EPDM'].map(idea => (
                    <div key={idea} style={{ padding: '8px 14px', background: 'var(--amber-bg)', color: 'var(--amber)', borderRadius: 8, fontSize: 13 }}>{idea}</div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Detection warning */}
          {notes.length > 150 && (notes.includes('hésit') || notes.includes('retour') || notes.includes('non,')) && (
            <div style={{ background: '#FFF0F0', border: '1px solid #F0A0A0', borderRadius: 8, padding: '8px 14px', fontSize: 13, color: '#A32D2D' }}>
              ⚠ Hésitation détectée · retour arrière possible
            </div>
          )}
        </div>

        {/* Analysis panel */}
        <div style={{ width: 280, background: 'white', borderLeft: '1px solid var(--border)', padding: 16, display: 'flex', flexDirection: 'column', gap: 16 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <div style={{ width: 8, height: 8, borderRadius: '50%', background: running ? 'var(--green-mid)' : '#94A3B8' }} />
            <span style={{ fontSize: 13, fontWeight: 700, color: running ? 'var(--green)' : 'var(--gray)' }}>
              {running ? 'Analyse en cours' : 'En attente'}
            </span>
          </div>

          <ReasoningBars data={(displaySession.reasoning || []).map((r: any) => ({ type: r.type, pct: r.pct ?? r.percentage ?? 0 }))} title="Raisonnement détecté" />

          <div style={{ borderTop: '1px solid var(--border)', paddingTop: 12 }}>
            <div style={{ fontSize: 12, color: 'var(--gray)', marginBottom: 4 }}>Score créativité</div>
            <div style={{ fontSize: 22, fontWeight: 800, color: 'var(--purple)' }}>
              {displaySession.creativityScore}<span style={{ fontSize: 13, color: 'var(--gray)', fontWeight: 400 }}>/10</span>
            </div>
          </div>

          <div style={{ borderTop: '1px solid var(--border)', paddingTop: 12 }}>
            <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 10 }}>Événements captés</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              {(displaySession.events || []).map((ev: any) => (
                <div key={ev.id} style={{ display: 'flex', gap: 8 }}>
                  <div style={{ width: 8, height: 8, borderRadius: '50%', background: eventDotColors[ev.type] || 'var(--purple)', marginTop: 4, flexShrink: 0 }} />
                  <div>
                    <div style={{ fontSize: 12, color: 'var(--dark)', fontWeight: 500 }}>{ev.label}</div>
                    <div style={{ fontSize: 11, color: 'var(--gray)' }}>{ev.timestamp}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div style={{ borderTop: '1px solid var(--border)', paddingTop: 12, marginTop: 'auto' }}>
            <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 8 }}>Ressources</div>
            {['Catalogue matériaux SENELEC', 'Norme ISO 1461'].map(r => (
              <div key={r} style={{ fontSize: 12, color: 'var(--purple)', padding: '4px 0', borderBottom: '1px solid var(--border)', cursor: 'pointer' }}>
                📎 {r}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Workspace;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\pages\Workspace.tsx"), $file1)
Write-Host "  OK  src/pages/Workspace.tsx"

Write-Host ""
Write-Host "Correctif frontend applique." -ForegroundColor Green