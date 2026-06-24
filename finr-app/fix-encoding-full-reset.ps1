# FIN-R - RESET COMPLET FRONTEND avec encodage UTF-8 force (sans BOM)
# Corrige tous les problemes d'accents (Ã©, Ã , etc.)
$ErrorActionPreference = "Stop"
Write-Host "Reinstallation complete du frontend en UTF-8..." -ForegroundColor Cyan

$Utf8NoBom = New-Object System.Text.UTF8Encoding $false

# ---------- src/pages/Login.tsx ----------
$file0 = @'
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import api from '../lib/api';
import { FlaskConical, Loader } from 'lucide-react';

const Login: React.FC = () => {
  const navigate = useNavigate();
  const { login, isAuthenticated, user, isLoading: authLoading } = useAuth();

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

  // Si l'utilisateur est déjà connecté (ex: redirigé ici par ProtectedRoute
  // après avoir tenté d'accéder à une page réservée à un autre rôle),
  // on le renvoie automatiquement vers sa bonne destination.
  useEffect(() => {
    if (!authLoading && isAuthenticated && user) {
      if (user.role === 'engineer') {
        redirectEngineer();
      } else {
        navigate('/dashboard');
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [authLoading, isAuthenticated, user]);

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
[System.IO.File]::WriteAllText((Join-Path $PWD "src\pages\Login.tsx"), $file0, $Utf8NoBom)
Write-Host "  OK  src/pages/Login.tsx"

# ---------- src/pages/Workspace.tsx ----------
$file1 = @'
import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useSession } from '../hooks/useSession';
import ReasoningBars from '../components/shared/ReasoningBars';
import { FlaskConical, Square, RotateCcw, Lightbulb, FileText, Grid, List, Wifi, WifiOff } from 'lucide-react';
import { getEcho } from '../lib/echo';
import { useAuth } from '../context/AuthContext';

type Tab = 'notes' | 'schema' | 'etapes' | 'idees';

const Workspace: React.FC = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
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
    if (user?.role === 'engineer') {
      navigate(`/session-completed/${id}`);
    } else {
      navigate(`/sessions/${id}`);
    }
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
[System.IO.File]::WriteAllText((Join-Path $PWD "src\pages\Workspace.tsx"), $file1, $Utf8NoBom)
Write-Host "  OK  src/pages/Workspace.tsx"

# ---------- src/pages/SessionCompleted.tsx ----------
$file2 = @'
import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { CheckCircle2, LogOut } from 'lucide-react';

/**
 * Page affichée à un ingénieur après avoir terminé sa session.
 * Il n'a pas accès au détail/analyse (réservé au chercheur),
 * juste une confirmation.
 */
const SessionCompleted: React.FC = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const { logout, user } = useAuth();

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  return (
    <div style={{
      minHeight: '100vh', background: 'var(--dark)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      flexDirection: 'column', gap: 16, padding: 24,
    }}>
      <div style={{
        width: 64, height: 64, borderRadius: '50%',
        background: 'var(--green-bg)', display: 'flex',
        alignItems: 'center', justifyContent: 'center',
      }}>
        <CheckCircle2 size={32} color="var(--green-mid)" />
      </div>
      <h1 style={{ color: 'white', fontSize: 22, fontWeight: 800 }}>Session terminée</h1>
      <p style={{ color: '#B0AECF', fontSize: 14, textAlign: 'center', maxWidth: 380 }}>
        Merci {user?.name?.split(' ')[0] || ''} ! Votre session #{id} a bien été enregistrée.
        Votre chercheur référent pourra consulter l'analyse complète de votre raisonnement.
      </p>
      <button
        onClick={handleLogout}
        style={{
          display: 'flex', alignItems: 'center', gap: 8,
          marginTop: 12, padding: '10px 22px', borderRadius: 8,
          background: 'var(--purple)', color: 'white', fontWeight: 600, fontSize: 14,
        }}
      >
        <LogOut size={15} /> Se déconnecter
      </button>
    </div>
  );
};

export default SessionCompleted;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\pages\SessionCompleted.tsx"), $file2, $Utf8NoBom)
Write-Host "  OK  src/pages/SessionCompleted.tsx"

# ---------- src/components/layout/ProtectedRoute.tsx ----------
$file3 = @'
import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

interface Props {
  children: React.ReactNode;
  roles?: Array<'researcher' | 'engineer'>;
}

const ProtectedRoute: React.FC<Props> = ({ children, roles }) => {
  const { isAuthenticated, isLoading, user } = useAuth();

  if (isLoading) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--dark)' }}>
        <div style={{ color: 'var(--purple-light)', fontSize: 14 }}>Chargement...</div>
      </div>
    );
  }

  if (!isAuthenticated) return <Navigate to="/" replace />;

  if (roles && user && !roles.includes(user.role)) {
    // Un utilisateur sans le bon rôle est renvoyé vers la page de connexion,
    // qui se chargera de le rediriger correctement selon son rôle réel
    // (dashboard pour chercheur, sa propre session pour ingénieur).
    return <Navigate to="/" replace />;
  }

  return <>{children}</>;
};

export default ProtectedRoute;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\components\layout\ProtectedRoute.tsx"), $file3, $Utf8NoBom)
Write-Host "  OK  src/components/layout/ProtectedRoute.tsx"

# ---------- src/App.tsx ----------
$file4 = @'
import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import ProtectedRoute from './components/layout/ProtectedRoute';
import AppLayout from './components/layout/AppLayout';

import Login        from './pages/Login';
import Dashboard    from './pages/Dashboard';
import Engineers    from './pages/Engineers';
import Sessions     from './pages/Sessions';
import SessionDetail from './pages/SessionDetail';
import NewSession   from './pages/NewSession';
import Workspace    from './pages/Workspace';
import SessionCompleted from './pages/SessionCompleted';
import Reasoning    from './pages/Reasoning';
import Stats        from './pages/Stats';
import Reports      from './pages/Reports';

const R = ({ el }: { el: React.ReactNode }) => (
  <ProtectedRoute roles={['researcher']}>
    <AppLayout>{el}</AppLayout>
  </ProtectedRoute>
);

const App: React.FC = () => (
  <AuthProvider>
    <BrowserRouter>
      <Routes>
        <Route path="/"              element={<Login />} />
        <Route path="/dashboard"     element={<R el={<Dashboard />} />} />
        <Route path="/engineers"     element={<R el={<Engineers />} />} />
        <Route path="/sessions"      element={<R el={<Sessions />} />} />
        <Route path="/sessions/new"  element={<R el={<NewSession />} />} />
        <Route path="/sessions/:id"  element={<R el={<SessionDetail />} />} />
        <Route path="/reasoning"     element={<R el={<Reasoning />} />} />
        <Route path="/stats"         element={<R el={<Stats />} />} />
        <Route path="/reports"       element={<R el={<Reports />} />} />
        <Route path="/workspace/:id" element={
          <ProtectedRoute>
            <Workspace />
          </ProtectedRoute>
        } />
        <Route path="/session-completed/:id" element={
          <ProtectedRoute roles={['engineer']}>
            <SessionCompleted />
          </ProtectedRoute>
        } />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </BrowserRouter>
  </AuthProvider>
);

export default App;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\App.tsx"), $file4, $Utf8NoBom)
Write-Host "  OK  src/App.tsx"

# ---------- src/pages/Dashboard.tsx ----------
$file5 = @'
import React from 'react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import { useSessions, useGlobalStats } from '../hooks/useSessions';
import { useEngineers } from '../hooks/useEngineers';
import { reasoningColors } from '../data/mockData';
import MetricCard from '../components/dashboard/MetricCard';
import SessionList from '../components/dashboard/SessionList';
import ReasoningBars from '../components/shared/ReasoningBars';
import { ReasoningType } from '../types';
import { PlusCircle, Loader } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const MONTHS = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'];

const Dashboard: React.FC = () => {
  const navigate = useNavigate();
  const { sessions, isLoading: loadingSessions } = useSessions();
  const { engineers, isLoading: loadingEngineers } = useEngineers();
  const { stats, isLoading: loadingStats } = useGlobalStats();

  // Compute monthly data from real sessions
  const monthlyData = React.useMemo(() => {
    const counts: Record<string, number> = {};
    sessions.forEach(s => {
      const d = new Date(s.started_at || s.date || '');
      if (!isNaN(d.getTime())) {
        const key = MONTHS[d.getMonth()];
        counts[key] = (counts[key] || 0) + 1;
      }
    });
    // Last 5 months
    const now = new Date();
    return Array.from({ length: 5 }, (_, i) => {
      const m = new Date(now.getFullYear(), now.getMonth() - 4 + i, 1);
      const label = MONTHS[m.getMonth()];
      return { month: label, sessions: counts[label] || 0 };
    });
  }, [sessions]);

  // Reasoning distribution from real sessions
  const reasoningDist = React.useMemo(() => {
    if (stats?.reasoning_distribution) {
      return stats.reasoning_distribution.map((r: any) => ({
        type: r.type as ReasoningType,
        pct: Math.round(r.avg_pct),
      }));
    }
    // Fallback: compute from sessions
    const totals: Record<string, number> = {};
    sessions.forEach(s => s.reasoning?.forEach((r: any) => {
      totals[r.type] = (totals[r.type] || 0) + r.pct;
    }));
    const total = Object.values(totals).reduce((a, b) => a + b, 0) || 1;
    return Object.entries(totals).map(([type, v]) => ({
      type: type as ReasoningType,
      pct: Math.round((v / total) * 100),
    })).sort((a, b) => b.pct - a.pct);
  }, [sessions, stats]);

  const dominantReasoning = reasoningDist[0]?.type || '—';
  const avgCreativity = sessions.length
    ? (sessions.reduce((a, s) => a + (s.creativity_score || s.creativityScore || 0), 0) / sessions.length).toFixed(1)
    : '—';

  const isLoading = loadingSessions || loadingEngineers;

  if (isLoading) return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: 300, gap: 10, color: 'var(--gray)' }}>
      <Loader size={18} style={{ animation: 'spin 1s linear infinite' }} /> Chargement...
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );

  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 28 }}>
        <div>
          <h1 style={{ fontSize: 24, fontWeight: 800, color: 'var(--dark)', marginBottom: 4 }}>Vue d'ensemble</h1>
          <p style={{ fontSize: 14, color: 'var(--gray)' }}>Tableau de bord — ESP/UCAD</p>
        </div>
        <button onClick={() => navigate('/sessions/new')} style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--purple)', color: 'white', padding: '10px 18px', borderRadius: 8, fontWeight: 600, fontSize: 14 }}>
          <PlusCircle size={16} /> Nouvelle session
        </button>
      </div>

      {/* Metrics */}
      <div style={{ display: 'flex', gap: 16, marginBottom: 24 }}>
        <MetricCard label="Sessions totales" value={String(stats?.total_sessions ?? sessions.length)} sub={`${stats?.completed_sessions ?? 0} terminées`} subPositive={true} />
        <MetricCard label="Ingénieurs suivis" value={String(engineers.length)} sub={`${engineers.length} enregistrés`} />
        <MetricCard label="Raisonnement dominant" value={dominantReasoning} sub={`${reasoningDist[0]?.pct ?? 0}% des sessions`} accent={true} />
        <MetricCard label="Score créativité moy." value={avgCreativity === '—' ? '—' : `${avgCreativity}/10`} sub="moyenne générale" subPositive={true} />
      </div>

      {/* Main grid */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 20, marginBottom: 20 }}>
        <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }}>
          <SessionList sessions={sessions} limit={4} />
          <button onClick={() => navigate('/sessions')} style={{ marginTop: 12, fontSize: 13, color: 'var(--purple)', fontWeight: 600, width: '100%', textAlign: 'center', padding: '6px 0' }}>
            Voir toutes les sessions →
          </button>
        </div>

        <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }}>
          {reasoningDist.length > 0
            ? <ReasoningBars data={reasoningDist} title="Répartition des raisonnements" />
            : <p style={{ fontSize: 13, color: 'var(--gray)', textAlign: 'center', marginTop: 40 }}>Aucune donnée disponible</p>
          }
        </div>

        <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 16 }}>Sessions par mois</div>
          <ResponsiveContainer width="100%" height={180}>
            <BarChart data={monthlyData} barSize={28}>
              <XAxis dataKey="month" tick={{ fontSize: 12, fill: '#64748B' }} axisLine={false} tickLine={false} />
              <YAxis hide />
              <Tooltip cursor={{ fill: 'var(--purple-light)' }} contentStyle={{ border: '1px solid var(--border)', borderRadius: 8, fontSize: 12 }} />
              <Bar dataKey="sessions" radius={[6, 6, 0, 0]}>
                {monthlyData.map((_, i) => (
                  <Cell key={i} fill={i === monthlyData.length - 1 ? 'var(--purple)' : '#DDDAF5'} />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Engineers table */}
      <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase' }}>Ingénieurs récents</div>
          <button onClick={() => navigate('/engineers')} style={{ fontSize: 13, color: 'var(--purple)', fontWeight: 600 }}>Voir tous →</button>
        </div>
        {engineers.length === 0
          ? <p style={{ fontSize: 13, color: 'var(--gray)', textAlign: 'center', padding: '20px 0' }}>Aucun ingénieur enregistré.</p>
          : (
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--border)' }}>
                {['Nom', 'Spécialité', 'Sessions', 'Dernière session', 'Raisonnement dominant'].map(h => (
                  <th key={h} style={{ fontSize: 12, color: 'var(--gray)', fontWeight: 600, textAlign: 'left', padding: '0 16px 10px 0' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {engineers.slice(0, 4).map(eng => {
                const col = reasoningColors[(eng.dominant_reasoning || eng.dominantReasoning) as ReasoningType] || 'var(--purple)';
                return (
                  <tr key={eng.id} style={{ borderBottom: '1px solid var(--border)' }}>
                    <td style={{ padding: '12px 16px 12px 0' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <div style={{ width: 32, height: 32, borderRadius: '50%', background: 'var(--purple-light)', color: 'var(--purple-dark)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 700, flexShrink: 0 }}>
                          {eng.initials}
                        </div>
                        <div>
                          <div style={{ fontWeight: 600, fontSize: 13 }}>{eng.name}</div>
                          <div style={{ fontSize: 11, color: 'var(--gray)' }}>{eng.email}</div>
                        </div>
                      </div>
                    </td>
                    <td style={{ fontSize: 13, color: 'var(--gray)', paddingRight: 16 }}>{eng.specialty}</td>
                    <td style={{ fontSize: 13, fontWeight: 600, paddingRight: 16 }}>{eng.sessions_count ?? eng.sessionsCount ?? 0}</td>
                    <td style={{ fontSize: 13, color: 'var(--gray)', paddingRight: 16 }}>{eng.last_session ?? eng.lastSession ?? '—'}</td>
                    <td>
                      <span style={{ background: col + '20', color: col, borderRadius: 20, padding: '3px 10px', fontSize: 12, fontWeight: 600 }}>
                        {eng.dominant_reasoning ?? eng.dominantReasoning ?? '—'}
                      </span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
};

export default Dashboard;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\pages\Dashboard.tsx"), $file5, $Utf8NoBom)
Write-Host "  OK  src/pages/Dashboard.tsx"

# ---------- src/pages/Sessions.tsx ----------
$file6 = @'
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSessions } from '../hooks/useSessions';
import { Avatar, ReasoningPill } from '../components/shared/Pill';
import { ReasoningType } from '../types';
import { PlusCircle, Search, Clock, Star, Loader } from 'lucide-react';

const Sessions: React.FC = () => {
  const navigate = useNavigate();
  const { sessions, isLoading, error } = useSessions();
  const [search, setSearch] = useState('');

  const filtered = sessions.filter(s =>
    s.engineerName?.toLowerCase().includes(search.toLowerCase()) ||
    s.engineer_name?.toLowerCase().includes(search.toLowerCase()) ||
    s.problem?.toLowerCase().includes(search.toLowerCase())
  );

  const statusColors: Record<string, string> = {
    completed: 'var(--green-mid)', active: 'var(--purple)', paused: 'var(--amber-mid)', draft: 'var(--gray)',
  };
  const statusLabels: Record<string, string> = {
    completed: 'Terminée', active: 'En cours', paused: 'En pause', draft: 'Brouillon',
  };

  if (isLoading) return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: 300, gap: 10, color: 'var(--gray)' }}>
      <Loader size={18} style={{ animation: 'spin 1s linear infinite' }} /> Chargement...
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
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
          style={{ width: '100%', padding: '9px 12px 9px 36px', border: '1px solid var(--border)', borderRadius: 8, fontSize: 14, background: 'white', outline: 'none' }} />
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
            <div key={s.id} onClick={() => navigate(`/sessions/${s.id}`)}
              style={{ background: 'white', borderRadius: 'var(--radius)', border: '1px solid var(--border)', boxShadow: 'var(--shadow)', padding: 20, cursor: 'pointer', transition: 'box-shadow 0.15s' }}
              onMouseEnter={e => (e.currentTarget.style.boxShadow = '0 4px 20px rgba(83,74,183,0.14)')}
              onMouseLeave={e => (e.currentTarget.style.boxShadow = 'var(--shadow)')}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 14 }}>
                <Avatar initials={initials} size={40} />
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 4, flexWrap: 'wrap' }}>
                    <span style={{ fontWeight: 700, fontSize: 15 }}>{name}</span>
                    <span style={{ fontSize: 12, color: statusColors[s.status] || 'var(--gray)', fontWeight: 600 }}>
                      ● {statusLabels[s.status] || s.status}
                    </span>
                    {dominant && <ReasoningPill type={dominant as ReasoningType} size="sm" />}
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
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default Sessions;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\pages\Sessions.tsx"), $file6, $Utf8NoBom)
Write-Host "  OK  src/pages/Sessions.tsx"

# ---------- src/pages/SessionDetail.tsx ----------
$file7 = @'
import React from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useSession } from '../hooks/useSession';
import { ReasoningPill } from '../components/shared/Pill';
import { Avatar } from '../components/shared/Pill';
import { ReasoningType } from '../types';
import ReasoningBars from '../components/shared/ReasoningBars';
import { reasoningColors } from '../data/mockData';
import { RadarChart, Radar, PolarGrid, PolarAngleAxis, ResponsiveContainer, Tooltip } from 'recharts';
import { ArrowLeft, Clock, Star, Zap, ArrowRight, Loader } from 'lucide-react';

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
        {session.status !== 'completed' && (
          <button onClick={() => navigate(`/workspace/${session.id}`)}
            style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--green-mid)', color: 'white', padding: '10px 18px', borderRadius: 8, fontWeight: 600, fontSize: 14 }}>
            Ouvrir l'espace travail <ArrowRight size={15} />
          </button>
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
          <div key={item.label} style={{ background: 'white', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow)', display: 'flex', alignItems: 'center', gap: 16 }}>
            <div style={{ width: 48, height: 48, borderRadius: 12, background: item.bg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{item.icon}</div>
            <div>
              <div style={{ fontSize: 12, color: 'var(--gray)', marginBottom: 4 }}>{item.label}</div>
              <div style={{ fontSize: 26, fontWeight: 800, color: item.color }}>{item.value}</div>
            </div>
          </div>
        ))}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
        <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }}>
          {reasoning.length > 0
            ? <ReasoningBars data={reasoning.map((r: any) => ({ type: r.type, pct: r.pct ?? r.percentage ?? 0 }))} title="Raisonnement détecté" />
            : <p style={{ fontSize: 13, color: 'var(--gray)' }}>Pas encore de données NLP.</p>}
        </div>

        <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }}>
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

        <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 12 }}>Notes de l'ingénieur</div>
          {session.notes
            ? <p style={{ fontSize: 14, color: 'var(--dark)', lineHeight: 1.7, whiteSpace: 'pre-line' }}>{session.notes}</p>
            : <p style={{ fontSize: 13, color: 'var(--gray)' }}>Aucune note.</p>}
        </div>

        <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }}>
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

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\pages\SessionDetail.tsx"), $file7, $Utf8NoBom)
Write-Host "  OK  src/pages/SessionDetail.tsx"

# ---------- src/pages/NewSession.tsx ----------
$file8 = @'
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useEngineers } from '../hooks/useEngineers';
import { useSessions } from '../hooks/useSessions';
import { ArrowLeft, PlayCircle, Loader } from 'lucide-react';

const NewSession: React.FC = () => {
  const navigate = useNavigate();
  const { engineers, isLoading: loadingEng } = useEngineers();
  const { createSession } = useSessions();
  const [form, setForm] = useState({ engineerId: '', problem: '', notes: '' });
  const [error, setError] = useState('');
  const [saving, setSaving] = useState(false);

  const handleStart = async () => {
    if (!form.engineerId || !form.problem.trim()) { setError('Veuillez sélectionner un ingénieur et saisir un problème.'); return; }
    setSaving(true); setError('');
    try {
      const session = await createSession(form.engineerId, form.problem);
      navigate(`/workspace/${session.id}`);
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

      <div style={{ background: 'white', borderRadius: 'var(--radius)', border: '1px solid var(--border)', boxShadow: 'var(--shadow)', padding: 28, display: 'flex', flexDirection: 'column', gap: 20 }}>
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

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\pages\NewSession.tsx"), $file8, $Utf8NoBom)
Write-Host "  OK  src/pages/NewSession.tsx"

# ---------- src/pages/Engineers.tsx ----------
$file9 = @'
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useEngineers } from '../hooks/useEngineers';
import { ReasoningType } from '../types';
import { reasoningColors } from '../data/mockData';
import { Search, PlusCircle, Mail, Brain, Loader, X } from 'lucide-react';

const Engineers: React.FC = () => {
  const navigate = useNavigate();
  const { engineers, isLoading, error, createEngineer } = useEngineers();
  const [search, setSearch] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ name: '', email: '', specialty: '' });
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState('');

  const filtered = engineers.filter(e =>
    e.name?.toLowerCase().includes(search.toLowerCase()) ||
    e.specialty?.toLowerCase().includes(search.toLowerCase())
  );

  const handleCreate = async (ev: React.FormEvent) => {
    ev.preventDefault();
    if (!form.name || !form.email || !form.specialty) { setFormError('Tous les champs sont requis.'); return; }
    setSaving(true); setFormError('');
    try {
      await createEngineer(form.name, form.email, form.specialty);
      setShowForm(false); setForm({ name: '', email: '', specialty: '' });
    } catch (e: any) {
      setFormError(e.response?.data?.message || 'Erreur lors de la création.');
    } finally { setSaving(false); }
  };

  if (isLoading) return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: 300, gap: 10, color: 'var(--gray)' }}>
      <Loader size={18} style={{ animation: 'spin 1s linear infinite' }} /> Chargement...
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
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
          <form onSubmit={handleCreate} style={{ background: 'white', borderRadius: 16, padding: 28, width: 420, display: 'flex', flexDirection: 'column', gap: 16 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <h2 style={{ fontSize: 18, fontWeight: 700 }}>Nouvel ingénieur</h2>
              <button type="button" onClick={() => setShowForm(false)}><X size={18} color="var(--gray)" /></button>
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
          style={{ width: '100%', padding: '9px 12px 9px 36px', border: '1px solid var(--border)', borderRadius: 8, fontSize: 14, background: 'white', outline: 'none' }} />
      </div>

      {error && <div style={{ background: 'var(--red-bg)', color: 'var(--red)', borderRadius: 8, padding: '10px 14px', fontSize: 13, marginBottom: 16 }}>⚠ {error}</div>}

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: 16 }}>
        {filtered.map(eng => {
          const col = reasoningColors[(eng.dominant_reasoning || eng.dominantReasoning) as ReasoningType] || 'var(--purple)';
          const sessCount = eng.sessions_count ?? eng.sessionsCount ?? 0;
          const avgScore = eng.avg_creativity ?? eng.averageCreativityScore ?? '—';
          const lastSess = eng.last_session ?? eng.lastSession ?? '—';
          return (
            <div key={eng.id}
              onClick={() => navigate(`/sessions?engineer=${eng.id}`)}
              style={{ background: 'white', borderRadius: 'var(--radius)', border: '1px solid var(--border)', boxShadow: 'var(--shadow)', padding: 20, cursor: 'pointer', transition: 'box-shadow 0.15s' }}
              onMouseEnter={e => (e.currentTarget.style.boxShadow = '0 4px 20px rgba(83,74,183,0.14)')}
              onMouseLeave={e => (e.currentTarget.style.boxShadow = 'var(--shadow)')}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 14 }}>
                <div style={{ width: 44, height: 44, borderRadius: '50%', background: 'var(--purple-light)', color: 'var(--purple-dark)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 15, fontWeight: 700 }}>
                  {eng.initials}
                </div>
                <div>
                  <div style={{ fontWeight: 700, fontSize: 15 }}>{eng.name}</div>
                  <div style={{ fontSize: 12, color: 'var(--gray)' }}>{eng.specialty}</div>
                </div>
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
    </div>
  );
};

export default Engineers;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\pages\Engineers.tsx"), $file9, $Utf8NoBom)
Write-Host "  OK  src/pages/Engineers.tsx"

# ---------- src/pages/Reasoning.tsx ----------
$file10 = @'
import React, { useState } from 'react';
import { useSessions } from '../hooks/useSessions';
import { reasoningColors, reasoningBgColors, reasoningTextColors } from '../data/mockData';
import { ReasoningType } from '../types';
import { Loader } from 'lucide-react';

const TYPES: ReasoningType[] = ['Analytique', 'Créatif', 'Par analogie', 'Essai-erreur', 'Systémique'];

const DESCRIPTIONS: Record<ReasoningType, string> = {
  'Analytique': "Décomposition logique du problème en sous-parties. Approche structurée, séquentielle. Utilisation de modèles mathématiques et de données chiffrées.",
  'Créatif': "Génération de solutions originales, divergentes. Associations inattendues, pensée latérale. Forte composante imagination.",
  'Par analogie': "Transposition de solutions connues d'autres domaines. Reconnaissance de structures similaires. Biomimétisme, références culturelles ou techniques.",
  'Essai-erreur': "Exploration empirique par itérations successives. Hypothèses testées et invalidées rapidement. Forte résilience au feedback négatif.",
  'Systémique': "Vision globale, prise en compte des interdépendances. Analyse des effets de bord. Modélisation des flux et des relations.",
};

const Reasoning: React.FC = () => {
  const { sessions, isLoading } = useSessions();
  const [selected, setSelected] = useState<ReasoningType>('Analytique');

  if (isLoading) return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: 300, gap: 10, color: 'var(--gray)' }}>
      <Loader size={18} style={{ animation: 'spin 1s linear infinite' }} /> Chargement...
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );

  const related = sessions.filter(s => (s.dominantReasoning || s.dominant_reasoning) === selected);
  const avgScore = related.length
    ? (related.reduce((a, s) => a + (s.creativityScore ?? s.creativity_score ?? 0), 0) / related.length).toFixed(1)
    : '—';
  const avgPresence = sessions.length === 0 ? 0 : Math.round(
    sessions.reduce((acc, s) => {
      const r = (s.reasoning || []).find((r: any) => r.type === selected);
      return acc + (r ? (r.pct ?? r.percentage ?? 0) : 0);
    }, 0) / sessions.length
  );

  const col = reasoningColors[selected];
  const bg = reasoningBgColors[selected];
  const txtCol = reasoningTextColors[selected];

  return (
    <div>
      <div style={{ marginBottom: 28 }}>
        <h1 style={{ fontSize: 24, fontWeight: 800, color: 'var(--dark)', marginBottom: 4 }}>Raisonnements</h1>
        <p style={{ fontSize: 14, color: 'var(--gray)' }}>Exploration des 5 types de raisonnement détectés</p>
      </div>

      <div style={{ display: 'flex', gap: 10, marginBottom: 24, flexWrap: 'wrap' }}>
        {TYPES.map(t => (
          <button key={t} onClick={() => setSelected(t)} style={{
            padding: '8px 18px', borderRadius: 20, fontWeight: 600, fontSize: 13,
            background: selected === t ? reasoningBgColors[t] : 'white',
            color: selected === t ? reasoningTextColors[t] : 'var(--gray)',
            border: `2px solid ${selected === t ? reasoningColors[t] : 'var(--border)'}`,
            transition: 'all 0.15s',
          }}>{t}</button>
        ))}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20 }}>
        <div style={{ background: bg, borderRadius: 'var(--radius)', padding: 24, border: `1px solid ${col}40`, gridColumn: '1 / -1' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
            <div style={{ width: 16, height: 16, borderRadius: '50%', background: col }} />
            <span style={{ fontSize: 20, fontWeight: 800, color: txtCol }}>{selected}</span>
          </div>
          <p style={{ fontSize: 15, color: 'var(--dark)', lineHeight: 1.7 }}>{DESCRIPTIONS[selected]}</p>
        </div>

        <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 24, border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 16 }}>Statistiques</div>
          <div style={{ display: 'flex', gap: 32 }}>
            <div><div style={{ fontSize: 32, fontWeight: 800, color: col }}>{related.length}</div><div style={{ fontSize: 12, color: 'var(--gray)' }}>sessions dominantes</div></div>
            <div><div style={{ fontSize: 32, fontWeight: 800, color: 'var(--dark)' }}>{avgScore}</div><div style={{ fontSize: 12, color: 'var(--gray)' }}>créativité moy.</div></div>
            <div><div style={{ fontSize: 32, fontWeight: 800, color: 'var(--dark)' }}>{avgPresence}%</div><div style={{ fontSize: 12, color: 'var(--gray)' }}>présence moyenne</div></div>
          </div>
        </div>

        <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 24, border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 14 }}>Sessions dominantes</div>
          {related.length === 0
            ? <p style={{ fontSize: 13, color: 'var(--gray)' }}>Aucune session avec ce raisonnement dominant.</p>
            : related.map(s => {
                const name = s.engineerName || s.engineer_name || '—';
                const score = s.creativityScore ?? s.creativity_score;
                return (
                  <div key={s.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 0', borderBottom: '1px solid var(--border)' }}>
                    <div>
                      <div style={{ fontWeight: 600, fontSize: 13 }}>{name}</div>
                      <div style={{ fontSize: 11, color: 'var(--gray)' }}>{s.date} · {s.duration || '—'}</div>
                    </div>
                    <div style={{ fontSize: 18, fontWeight: 800, color: 'var(--purple)' }}>
                      {score != null ? <>{score}<span style={{ fontSize: 12, fontWeight: 400, color: 'var(--gray)' }}>/10</span></> : '—'}
                    </div>
                  </div>
                );
              })
          }
        </div>

        <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 24, border: '1px solid var(--border)', boxShadow: 'var(--shadow)', gridColumn: '1 / -1' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 16 }}>
            Présence de « {selected} » dans chaque session
          </div>
          {sessions.length === 0
            ? <p style={{ fontSize: 13, color: 'var(--gray)' }}>Aucune donnée.</p>
            : sessions.map(s => {
                const r = (s.reasoning || []).find((r: any) => r.type === selected);
                const pct = r ? (r.pct ?? r.percentage ?? 0) : 0;
                const name = s.engineerName || s.engineer_name || '—';
                return (
                  <div key={s.id} style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 10 }}>
                    <div style={{ width: 120, fontSize: 13, fontWeight: 500, flexShrink: 0 }}>{name.split(' ')[0]}</div>
                    <div style={{ flex: 1, background: '#EEECF8', borderRadius: 4, height: 8, overflow: 'hidden' }}>
                      <div style={{ height: '100%', width: `${pct}%`, background: col, borderRadius: 4, transition: 'width 0.6s ease' }} />
                    </div>
                    <div style={{ width: 40, textAlign: 'right', fontSize: 13, fontWeight: 600, color: 'var(--gray)' }}>{pct}%</div>
                  </div>
                );
              })
          }
        </div>
      </div>
    </div>
  );
};

export default Reasoning;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\pages\Reasoning.tsx"), $file10, $Utf8NoBom)
Write-Host "  OK  src/pages/Reasoning.tsx"

# ---------- src/pages/Stats.tsx ----------
$file11 = @'
import React from 'react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell, RadarChart, Radar, PolarGrid, PolarAngleAxis, LineChart, Line, CartesianGrid } from 'recharts';
import { useSessions } from '../hooks/useSessions';
import { reasoningColors } from '../data/mockData';
import { ReasoningType } from '../types';
import { Loader } from 'lucide-react';

const REASONING_TYPES: ReasoningType[] = ['Analytique', 'Créatif', 'Par analogie', 'Essai-erreur', 'Systémique'];

const Stats: React.FC = () => {
  const { sessions, isLoading } = useSessions();

  if (isLoading) return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: 300, gap: 10, color: 'var(--gray)' }}>
      <Loader size={18} style={{ animation: 'spin 1s linear infinite' }} /> Chargement...
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );

  // Compute from real sessions
  const globalReasoning = REASONING_TYPES.map(type => ({
    name: type,
    value: sessions.length === 0 ? 0 : Math.round(
      sessions.reduce((acc, s) => {
        const r = (s.reasoning || []).find((r: any) => r.type === type);
        return acc + (r ? (r.pct ?? r.percentage ?? 0) : 0);
      }, 0) / sessions.length
    ),
  }));

  const creativityOverTime = sessions.map((s, i) => ({
    name: (s.engineerName || s.engineer_name || `S${i+1}`).split(' ')[0],
    score: s.creativityScore ?? s.creativity_score ?? 0,
  }));

  const eventCounts = sessions.flatMap(s => s.events || []).reduce((acc: any, ev: any) => {
    acc[ev.type] = (acc[ev.type] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);

  const eventData = Object.entries(eventCounts).map(([type, count]) => ({
    name: ({ decomposition: 'Décomposition', analogy: 'Analogie', hesitation: 'Hésitation', insight: 'Insight', backtrack: 'Retour arrière' } as any)[type] || type,
    count,
  }));

  const radarData = REASONING_TYPES.map(type => ({
    subject: type,
    value: globalReasoning.find(r => r.name === type)?.value || 0,
  }));

  const card = (children: React.ReactNode, title: string) => (
    <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 24, border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }}>
      <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 16 }}>{title}</div>
      {children}
    </div>
  );

  if (sessions.length === 0) return (
    <div>
      <h1 style={{ fontSize: 24, fontWeight: 800, color: 'var(--dark)', marginBottom: 28 }}>Statistiques</h1>
      <div style={{ textAlign: 'center', padding: '80px 0', color: 'var(--gray)' }}>Aucune session terminée pour l'instant.</div>
    </div>
  );

  return (
    <div>
      <div style={{ marginBottom: 28 }}>
        <h1 style={{ fontSize: 24, fontWeight: 800, color: 'var(--dark)', marginBottom: 4 }}>Statistiques</h1>
        <p style={{ fontSize: 14, color: 'var(--gray)' }}>Analyse agrégée de {sessions.length} session{sessions.length > 1 ? 's' : ''}</p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20, marginBottom: 20 }}>
        {card(
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={globalReasoning} barSize={32}>
              <XAxis dataKey="name" tick={{ fontSize: 11, fill: '#64748B' }} axisLine={false} tickLine={false} />
              <YAxis hide />
              <Tooltip formatter={(v: number) => `${v}%`} contentStyle={{ borderRadius: 8, border: '1px solid var(--border)', fontSize: 12 }} />
              <Bar dataKey="value" radius={[6,6,0,0]}>
                {globalReasoning.map(e => <Cell key={e.name} fill={reasoningColors[e.name as ReasoningType] || '#ccc'} />)}
              </Bar>
            </BarChart>
          </ResponsiveContainer>,
          'Répartition globale des raisonnements'
        )}

        {card(
          <ResponsiveContainer width="100%" height={220}>
            <RadarChart data={radarData}>
              <PolarGrid stroke="var(--border)" />
              <PolarAngleAxis dataKey="subject" tick={{ fontSize: 11, fill: '#64748B' }} />
              <Radar name="Groupe" dataKey="value" stroke="var(--purple)" fill="var(--purple)" fillOpacity={0.25} />
              <Tooltip formatter={(v: number) => `${v}%`} contentStyle={{ borderRadius: 8, border: '1px solid var(--border)', fontSize: 12 }} />
            </RadarChart>
          </ResponsiveContainer>,
          'Profil cognitif moyen'
        )}

        {card(
          <ResponsiveContainer width="100%" height={220}>
            <LineChart data={creativityOverTime}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
              <XAxis dataKey="name" tick={{ fontSize: 11, fill: '#64748B' }} axisLine={false} tickLine={false} />
              <YAxis domain={[0, 10]} tick={{ fontSize: 11, fill: '#64748B' }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ borderRadius: 8, border: '1px solid var(--border)', fontSize: 12 }} />
              <Line type="monotone" dataKey="score" stroke="var(--purple)" strokeWidth={2.5} dot={{ fill: 'var(--purple)', r: 4 }} />
            </LineChart>
          </ResponsiveContainer>,
          'Score créativité par session'
        )}

        {card(
          eventData.length > 0
            ? <ResponsiveContainer width="100%" height={220}>
                <BarChart data={eventData} layout="vertical" barSize={18}>
                  <XAxis type="number" hide />
                  <YAxis dataKey="name" type="category" width={110} tick={{ fontSize: 12, fill: '#64748B' }} axisLine={false} tickLine={false} />
                  <Tooltip contentStyle={{ borderRadius: 8, border: '1px solid var(--border)', fontSize: 12 }} />
                  <Bar dataKey="count" fill="var(--purple-mid)" radius={[0,6,6,0]} />
                </BarChart>
              </ResponsiveContainer>
            : <p style={{ fontSize: 13, color: 'var(--gray)', textAlign: 'center', paddingTop: 40 }}>Aucun événement capté</p>,
          'Types d\'événements captés'
        )}
      </div>

      {/* Table */}
      <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 24, border: '1px solid var(--border)', boxShadow: 'var(--shadow)' }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 16 }}>Récapitulatif par session</div>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr style={{ borderBottom: '1px solid var(--border)' }}>
              {['Ingénieur', 'Durée', 'Créativité', 'Raisonnement dominant', 'Événements'].map(h => (
                <th key={h} style={{ fontSize: 12, color: 'var(--gray)', fontWeight: 600, textAlign: 'left', padding: '0 16px 10px 0' }}>{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {sessions.map(s => {
              const name = s.engineerName || s.engineer_name || '—';
              const score = s.creativityScore ?? s.creativity_score;
              const dominant = s.dominantReasoning || s.dominant_reasoning;
              const col = dominant ? (reasoningColors[dominant as ReasoningType] || '#ccc') : '#ccc';
              return (
                <tr key={s.id} style={{ borderBottom: '1px solid var(--border)' }}>
                  <td style={{ padding: '12px 16px 12px 0', fontWeight: 600, fontSize: 13 }}>{name}</td>
                  <td style={{ fontSize: 13, color: 'var(--gray)', paddingRight: 16 }}>{s.duration || '—'}</td>
                  <td style={{ fontSize: 13, fontWeight: 700, color: 'var(--purple)', paddingRight: 16 }}>{score != null ? `${score}/10` : '—'}</td>
                  <td style={{ paddingRight: 16 }}>
                    {dominant && <span style={{ background: col + '20', color: col, borderRadius: 20, padding: '3px 10px', fontSize: 12, fontWeight: 600 }}>{dominant}</span>}
                  </td>
                  <td style={{ fontSize: 13, color: 'var(--gray)' }}>{(s.events || []).length}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Stats;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\pages\Stats.tsx"), $file11, $Utf8NoBom)
Write-Host "  OK  src/pages/Stats.tsx"

# ---------- src/pages/Reports.tsx ----------
$file12 = @'
import React, { useState } from 'react';
import { useSessions } from '../hooks/useSessions';
import { ReasoningPill } from '../components/shared/Pill';
import { Download, FileText, Calendar, User, Brain, Star, Zap, Loader, Printer } from 'lucide-react';

const Reports: React.FC = () => {
  const { sessions, isLoading } = useSessions();
  const [selectedId, setSelectedId] = useState<string | null>(null);

  React.useEffect(() => {
    if (sessions.length > 0 && !selectedId) setSelectedId(String(sessions[0].id));
  }, [sessions, selectedId]);

  const session = sessions.find(s => String(s.id) === selectedId);

  const handlePrint = () => window.print();

  if (isLoading) return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: 300, gap: 10, color: 'var(--gray)' }}>
      <Loader size={18} style={{ animation: 'spin 1s linear infinite' }} /> Chargement...
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );

  if (sessions.length === 0) return (
    <div>
      <h1 style={{ fontSize: 24, fontWeight: 800, color: 'var(--dark)', marginBottom: 28 }}>Rapports</h1>
      <div style={{ textAlign: 'center', padding: '80px 0', color: 'var(--gray)' }}>Aucune session disponible.</div>
    </div>
  );

  return (
    <div>
      <div style={{ marginBottom: 28 }}>
        <h1 style={{ fontSize: 24, fontWeight: 800, color: 'var(--dark)', marginBottom: 4 }}>Rapports</h1>
        <p style={{ fontSize: 14, color: 'var(--gray)' }}>Génération de rapports par session</p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '260px 1fr', gap: 20 }}>
        {/* Session list */}
        <div style={{ background: 'white', borderRadius: 'var(--radius)', padding: 16, border: '1px solid var(--border)', boxShadow: 'var(--shadow)', height: 'fit-content' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 12 }}>Choisir une session</div>
          {sessions.map(s => {
            const name = s.engineerName || s.engineer_name || '—';
            const active = String(s.id) === selectedId;
            return (
              <button key={s.id} onClick={() => setSelectedId(String(s.id))} style={{
                width: '100%', textAlign: 'left', padding: '10px 12px', borderRadius: 8, marginBottom: 4,
                background: active ? 'var(--purple-light)' : 'transparent',
                border: `1px solid ${active ? '#AFA9EC' : 'transparent'}`, cursor: 'pointer',
              }}>
                <div style={{ fontWeight: 600, fontSize: 13, color: active ? 'var(--purple-dark)' : 'var(--dark)' }}>{name}</div>
                <div style={{ fontSize: 11, color: 'var(--gray)' }}>{s.date} · {s.duration || '—'}</div>
              </button>
            );
          })}
        </div>

        {/* Report preview */}
        {session && (() => {
          const name = session.engineerName || session.engineer_name || '—';
          const score = session.creativityScore ?? session.creativity_score;
          const dominant = session.dominantReasoning || session.dominant_reasoning;
          const reasoning = session.reasoning || [];
          const events = session.events || [];

          return (
            <div style={{ background: 'white', borderRadius: 'var(--radius)', border: '1px solid var(--border)', boxShadow: 'var(--shadow)', overflow: 'hidden' }}>
              {/* Header */}
              <div style={{ background: 'var(--dark)', padding: '20px 28px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <div style={{ color: 'var(--purple-light)', fontSize: 11, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase', marginBottom: 4 }}>FIN-R · Rapport de session</div>
                  <div style={{ color: 'white', fontSize: 20, fontWeight: 800 }}>{name}</div>
                  <div style={{ color: '#B0AECF', fontSize: 13, marginTop: 2 }}>{session.date} · {session.duration || '—'}</div>
                </div>
                <button onClick={handlePrint} style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--purple)', color: 'white', padding: '10px 18px', borderRadius: 8, fontWeight: 600, fontSize: 14 }}>
                  <Printer size={15} /> Imprimer / PDF
                </button>
              </div>

              <div style={{ padding: 28 }}>
                {/* Meta */}
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 12, marginBottom: 24 }}>
                  {[
                    { icon: <User size={14} />, label: 'Ingénieur', value: name },
                    { icon: <Calendar size={14} />, label: 'Date', value: session.date || '—' },
                    { icon: <Brain size={14} />, label: 'Raisonnement', value: dominant || '—' },
                    { icon: <Star size={14} />, label: 'Créativité', value: score != null ? `${score}/10` : '—' },
                  ].map(item => (
                    <div key={item.label} style={{ background: 'var(--light-bg)', borderRadius: 8, padding: '12px 14px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 11, color: 'var(--gray)', marginBottom: 4 }}>{item.icon} {item.label}</div>
                      <div style={{ fontSize: 13, fontWeight: 700, color: 'var(--dark)' }}>{item.value}</div>
                    </div>
                  ))}
                </div>

                {/* Problem */}
                <section style={{ marginBottom: 20 }}>
                  <h2 style={{ fontSize: 14, fontWeight: 700, color: 'var(--dark)', marginBottom: 8, display: 'flex', alignItems: 'center', gap: 8 }}>
                    <FileText size={14} color="var(--purple)" /> Problème soumis
                  </h2>
                  <div style={{ background: 'var(--purple-light)', borderRadius: 8, padding: '12px 16px', fontSize: 13, color: 'var(--purple-dark)', lineHeight: 1.6, border: '1px solid #AFA9EC' }}>
                    {session.problem}
                  </div>
                </section>

                {/* Notes */}
                {session.notes && (
                  <section style={{ marginBottom: 20 }}>
                    <h2 style={{ fontSize: 14, fontWeight: 700, color: 'var(--dark)', marginBottom: 8 }}>Notes de l'ingénieur</h2>
                    <p style={{ fontSize: 13, color: 'var(--dark)', lineHeight: 1.7, whiteSpace: 'pre-line' }}>{session.notes}</p>
                  </section>
                )}

                {/* Reasoning */}
                {reasoning.length > 0 && (
                  <section style={{ marginBottom: 20 }}>
                    <h2 style={{ fontSize: 14, fontWeight: 700, color: 'var(--dark)', marginBottom: 12 }}>Profil de raisonnement</h2>
                    {reasoning.map((r: any) => (
                      <div key={r.type} style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 8 }}>
                        <ReasoningPill type={r.type} size="sm" />
                        <div style={{ flex: 1, background: '#EEECF8', borderRadius: 4, height: 8, overflow: 'hidden' }}>
                          <div style={{ height: '100%', width: `${r.pct ?? r.percentage ?? 0}%`, background: '#7F77DD', borderRadius: 4 }} />
                        </div>
                        <span style={{ fontSize: 13, fontWeight: 600, width: 36, textAlign: 'right' }}>{r.pct ?? r.percentage ?? 0}%</span>
                      </div>
                    ))}
                  </section>
                )}

                {/* Events */}
                {events.length > 0 && (
                  <section>
                    <h2 style={{ fontSize: 14, fontWeight: 700, color: 'var(--dark)', marginBottom: 12, display: 'flex', alignItems: 'center', gap: 8 }}>
                      <Zap size={14} color="var(--amber-mid)" /> Événements captés ({events.length})
                    </h2>
                    <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                      <thead>
                        <tr style={{ borderBottom: '1px solid var(--border)' }}>
                          {['Horodatage', 'Type', 'Description'].map(h => (
                            <th key={h} style={{ fontSize: 12, color: 'var(--gray)', fontWeight: 600, textAlign: 'left', padding: '0 16px 8px 0' }}>{h}</th>
                          ))}
                        </tr>
                      </thead>
                      <tbody>
                        {events.map((ev: any) => (
                          <tr key={ev.id} style={{ borderBottom: '1px solid var(--border)' }}>
                            <td style={{ fontSize: 12, color: 'var(--gray)', padding: '10px 16px 10px 0', fontFamily: 'monospace' }}>{ev.timestamp}</td>
                            <td style={{ padding: '10px 16px 10px 0' }}>
                              <span style={{ fontSize: 12, fontWeight: 600, textTransform: 'capitalize', color: 'var(--purple)' }}>{ev.type}</span>
                            </td>
                            <td style={{ fontSize: 13, color: 'var(--dark)', padding: '10px 0' }}>{ev.label}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </section>
                )}
              </div>
            </div>
          );
        })()}
      </div>
      <style>{`@keyframes spin { to { transform: rotate(360deg); } } @media print { .no-print { display: none; } }`}</style>
    </div>
  );
};

export default Reports;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\pages\Reports.tsx"), $file12, $Utf8NoBom)
Write-Host "  OK  src/pages/Reports.tsx"

# ---------- src/components/layout/Sidebar.tsx ----------
$file13 = @'
import React from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { LayoutDashboard, Users, PlayCircle, Brain, BarChart2, FileText, LogOut, FlaskConical } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

const navItems = [
  { label: 'Dashboard',     icon: LayoutDashboard, path: '/dashboard' },
  { label: 'Ingénieurs',    icon: Users,           path: '/engineers' },
  { label: 'Sessions',      icon: PlayCircle,      path: '/sessions' },
  { label: 'Raisonnements', icon: Brain,           path: '/reasoning' },
  { label: 'Statistiques',  icon: BarChart2,       path: '/stats' },
  { label: 'Rapports',      icon: FileText,        path: '/reports' },
];

const Sidebar: React.FC = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { user, logout } = useAuth();

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  return (
    <aside style={{ width: 'var(--sidebar-width)', background: 'white', borderRight: '1px solid var(--border)', display: 'flex', flexDirection: 'column', height: '100vh', position: 'fixed', top: 0, left: 0, zIndex: 100 }}>
      <div style={{ padding: '20px 20px 16px', borderBottom: '1px solid var(--border)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <div style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--purple)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <FlaskConical size={16} color="white" />
          </div>
          <span style={{ fontWeight: 800, fontSize: 18, color: 'var(--purple)', letterSpacing: -0.5 }}>
            FIN<span style={{ color: 'var(--purple-mid)' }}>-R</span>
          </span>
        </div>
        <div style={{ fontSize: 11, color: 'var(--gray)', marginTop: 4, marginLeft: 40 }}>
          {user?.name || 'Chercheur'} · ESP/UCAD
        </div>
      </div>

      <nav style={{ flex: 1, padding: '12px', display: 'flex', flexDirection: 'column', gap: 2 }}>
        {navItems.map(item => {
          const active = location.pathname === item.path;
          const Icon = item.icon;
          return (
            <button key={item.path} onClick={() => navigate(item.path)} style={{
              display: 'flex', alignItems: 'center', gap: 10,
              padding: '9px 12px', borderRadius: 8,
              background: active ? 'var(--purple-light)' : 'transparent',
              color: active ? 'var(--purple)' : 'var(--gray)',
              fontWeight: active ? 600 : 400, fontSize: 14,
              transition: 'all 0.15s', width: '100%', textAlign: 'left',
            }}>
              <Icon size={16} />{item.label}
            </button>
          );
        })}
      </nav>

      <div style={{ padding: '12px', borderTop: '1px solid var(--border)' }}>
        <button onClick={handleLogout} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '9px 12px', borderRadius: 8, color: 'var(--gray)', fontSize: 14, width: '100%' }}>
          <LogOut size={16} /> Déconnexion
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\components\layout\Sidebar.tsx"), $file13, $Utf8NoBom)
Write-Host "  OK  src/components/layout/Sidebar.tsx"

# ---------- src/components/layout/AppLayout.tsx ----------
$file14 = @'
import React from 'react';
import Sidebar from './Sidebar';

interface AppLayoutProps {
  children: React.ReactNode;
}

const AppLayout: React.FC<AppLayoutProps> = ({ children }) => (
  <div style={{ display: 'flex', minHeight: '100vh' }}>
    <Sidebar />
    <main style={{
      marginLeft: 'var(--sidebar-width)',
      flex: 1,
      padding: '32px',
      minHeight: '100vh',
      background: 'var(--light-bg)',
    }}>
      {children}
    </main>
  </div>
);

export default AppLayout;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\components\layout\AppLayout.tsx"), $file14, $Utf8NoBom)
Write-Host "  OK  src/components/layout/AppLayout.tsx"

# ---------- src/components/dashboard/MetricCard.tsx ----------
$file15 = @'
import React from 'react';

interface MetricCardProps {
  label: string;
  value: string;
  sub: string;
  subPositive?: boolean;
  accent?: boolean;
}

const MetricCard: React.FC<MetricCardProps> = ({ label, value, sub, subPositive, accent }) => (
  <div style={{
    background: 'white',
    border: '1px solid var(--border)',
    borderRadius: 'var(--radius)',
    padding: '16px 20px',
    boxShadow: 'var(--shadow)',
    flex: 1,
    minWidth: 0,
  }}>
    <div style={{ fontSize: 12, color: 'var(--gray)', marginBottom: 6 }}>{label}</div>
    <div style={{
      fontSize: accent ? 20 : 28,
      fontWeight: 800,
      color: accent ? 'var(--purple)' : 'var(--dark)',
      lineHeight: 1.1,
      marginBottom: 4,
    }}>
      {value}
    </div>
    <div style={{
      fontSize: 12,
      color: subPositive !== undefined
        ? (subPositive ? 'var(--green-mid)' : 'var(--red-mid)')
        : 'var(--gray)',
    }}>
      {sub}
    </div>
  </div>
);

export default MetricCard;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\components\dashboard\MetricCard.tsx"), $file15, $Utf8NoBom)
Write-Host "  OK  src/components/dashboard/MetricCard.tsx"

# ---------- src/components/dashboard/SessionList.tsx ----------
$file16 = @'
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

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\components\dashboard\SessionList.tsx"), $file16, $Utf8NoBom)
Write-Host "  OK  src/components/dashboard/SessionList.tsx"

# ---------- src/components/shared/Pill.tsx ----------
$file17 = @'
import React from 'react';
import { reasoningBgColors, reasoningTextColors } from '../../data/mockData';
import { ReasoningType } from '../../types';

interface PillProps {
  type: ReasoningType;
  size?: 'sm' | 'md';
}

export const ReasoningPill: React.FC<PillProps> = ({ type, size = 'md' }) => {
  const bg = reasoningBgColors[type] || '#f0f0f0';
  const color = reasoningTextColors[type] || '#333';
  return (
    <span style={{
      display: 'inline-block',
      background: bg,
      color,
      borderRadius: 20,
      padding: size === 'sm' ? '2px 8px' : '4px 12px',
      fontSize: size === 'sm' ? 11 : 12,
      fontWeight: 600,
      whiteSpace: 'nowrap',
    }}>
      {type}
    </span>
  );
};

interface AvatarProps {
  initials: string;
  size?: number;
}

export const Avatar: React.FC<AvatarProps> = ({ initials, size = 36 }) => (
  <div style={{
    width: size, height: size, borderRadius: '50%',
    background: 'var(--purple-light)',
    color: 'var(--purple-dark)',
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    fontSize: size * 0.36, fontWeight: 700, flexShrink: 0,
  }}>
    {initials}
  </div>
);

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\components\shared\Pill.tsx"), $file17, $Utf8NoBom)
Write-Host "  OK  src/components/shared/Pill.tsx"

# ---------- src/components/shared/ReasoningBars.tsx ----------
$file18 = @'
import React from 'react';
import { reasoningColors } from '../../data/mockData';
import { ReasoningType } from '../../types';

interface Bar { type: ReasoningType; pct: number }

interface ReasoningBarsProps {
  data: Bar[];
  title?: string;
}

const ReasoningBars: React.FC<ReasoningBarsProps> = ({ data, title }) => (
  <div>
    {title && (
      <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 12 }}>
        {title}
      </div>
    )}
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      {data.map(b => (
        <div key={b.type}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4 }}>
            <span style={{ fontSize: 13, color: 'var(--gray)' }}>{b.type}</span>
            <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--dark)' }}>{b.pct}%</span>
          </div>
          <div style={{ background: '#EEECF8', borderRadius: 4, height: 6, overflow: 'hidden' }}>
            <div style={{
              height: '100%',
              width: `${b.pct}%`,
              background: reasoningColors[b.type] || 'var(--purple)',
              borderRadius: 4,
              transition: 'width 0.6s ease',
            }} />
          </div>
        </div>
      ))}
    </div>
  </div>
);

export default ReasoningBars;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\components\shared\ReasoningBars.tsx"), $file18, $Utf8NoBom)
Write-Host "  OK  src/components/shared/ReasoningBars.tsx"

# ---------- src/data/mockData.ts ----------
$file19 = @'
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

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\data\mockData.ts"), $file19, $Utf8NoBom)
Write-Host "  OK  src/data/mockData.ts"

# ---------- src/context/AuthContext.tsx ----------
$file20 = @'
/**
 * src/context/AuthContext.tsx
 * Contexte global d'authentification JWT.
 * Fournit : user, login(), logout(), isAuthenticated, isLoading
 */
import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import api from '../lib/api';

export interface AuthUser {
  id: number;
  name: string;
  email: string;
  role: 'researcher' | 'engineer';
}

interface AuthContextType {
  user: AuthUser | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  error: string | null;
}

const AuthContext = createContext<AuthContextType | null>(null);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [isLoading, setIsLoading] = useState(true); // true until we check localStorage
  const [error, setError] = useState<string | null>(null);

  // On mount: restore session from localStorage
  useEffect(() => {
    const stored = localStorage.getItem('finr_user');
    const token  = localStorage.getItem('finr_token');
    if (stored && token) {
      try {
        setUser(JSON.parse(stored));
      } catch {
        localStorage.removeItem('finr_user');
        localStorage.removeItem('finr_token');
      }
    }
    setIsLoading(false);
  }, []);

  const login = useCallback(async (email: string, password: string) => {
    setError(null);
    setIsLoading(true);
    try {
      const { data } = await api.post('/auth/login', { email, password });
      localStorage.setItem('finr_token', data.token);
      localStorage.setItem('finr_user', JSON.stringify(data.user));
      setUser(data.user);
    } catch (err: any) {
      const msg = err.response?.data?.message || 'Erreur de connexion.';
      setError(msg);
      throw new Error(msg);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const logout = useCallback(async () => {
    try {
      await api.post('/auth/logout');
    } catch { /* ignore */ }
    localStorage.removeItem('finr_token');
    localStorage.removeItem('finr_user');
    setUser(null);
  }, []);

  return (
    <AuthContext.Provider value={{
      user,
      isAuthenticated: !!user,
      isLoading,
      login,
      logout,
      error,
    }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider');
  return ctx;
};

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\context\AuthContext.tsx"), $file20, $Utf8NoBom)
Write-Host "  OK  src/context/AuthContext.tsx"

# ---------- src/hooks/useSession.ts ----------
$file21 = @'
/**
 * src/hooks/useSession.ts
 * Hook pour charger / mettre à jour une session via l'API réelle.
 * Remplace les accès directs à mockData dans les pages.
 */
import { useState, useEffect, useRef, useCallback } from 'react';
import api from '../lib/api';
import { getEcho } from '../lib/echo';
import { Session } from '../types';

interface UseSessionReturn {
  session: Session | null;
  isLoading: boolean;
  error: string | null;
  saveNotes: (notes: string) => Promise<void>;
  startSession: () => Promise<void>;
  endSession: () => Promise<void>;
  pauseSession: () => Promise<void>;
}

/**
 * Charge une session, s'abonne au canal WebSocket pour les updates live,
 * et expose les actions (start / pause / end / saveNotes).
 */
export function useSession(sessionId: string | undefined): UseSessionReturn {
  const [session, setSession] = useState<Session | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const saveTimer = useRef<NodeJS.Timeout | null>(null);

  // ── Fetch initial ──────────────────────────────────────────────────────
  useEffect(() => {
    if (!sessionId || sessionId === 'new') { setIsLoading(false); return; }

    let cancelled = false;
    setIsLoading(true);

    api.get(`/sessions/${sessionId}`)
      .then(({ data }) => { if (!cancelled) setSession(data); })
      .catch((e) => { if (!cancelled) setError(e.response?.data?.message || 'Erreur réseau.'); })
      .finally(() => { if (!cancelled) setIsLoading(false); });

    return () => { cancelled = true; };
  }, [sessionId]);

  // ── WebSocket subscription ─────────────────────────────────────────────
  useEffect(() => {
    if (!sessionId || sessionId === 'new') return;

    const echo = getEcho();
    const channel = echo.channel(`session.${sessionId}`);

    channel.listen('.session.updated', (payload: any) => {
      setSession((prev) => {
        if (!prev) return prev;
        return {
          ...prev,
          reasoning: payload.reasoning ?? prev.reasoning,
          creativityScore: payload.creativity_score ?? prev.creativityScore,
          events: payload.events?.length
            ? [...(prev.events || []), ...payload.events].slice(-20)
            : prev.events,
        };
      });
    });

    return () => {
      echo.leaveChannel(`session.${sessionId}`);
    };
  }, [sessionId]);

  // ── Actions ────────────────────────────────────────────────────────────

  const saveNotes = useCallback(async (notes: string) => {
    if (!sessionId) return;

    // Optimistic update
    setSession((prev) => prev ? { ...prev, notes } : prev);

    // Debounce: send to API after 3 s of inactivity
    if (saveTimer.current) clearTimeout(saveTimer.current);
    saveTimer.current = setTimeout(async () => {
      try {
        const { data } = await api.patch(`/sessions/${sessionId}/notes`, { notes });
        // Merge NLP response if scores updated
        if (data.scores) {
          setSession((prev) => {
            if (!prev) return prev;
            return {
              ...prev,
              reasoning: Object.entries(data.scores).map(([type, pct]) => ({
                type: type as any,
                pct: pct as number,
              })),
              creativityScore: data.creativity_score ?? prev.creativityScore,
            };
          });
        }
      } catch (e: any) {
        console.warn('Notes save failed:', e.message);
      }
    }, 3000);
  }, [sessionId]);

  const startSession = useCallback(async () => {
    if (!sessionId) return;
    const { data } = await api.post(`/sessions/${sessionId}/start`);
    setSession(data);
  }, [sessionId]);

  const pauseSession = useCallback(async () => {
    if (!sessionId) return;
    const { data } = await api.post(`/sessions/${sessionId}/pause`);
    setSession(data);
  }, [sessionId]);

  const endSession = useCallback(async () => {
    if (!sessionId) return;
    const { data } = await api.post(`/sessions/${sessionId}/end`);
    setSession(data);
  }, [sessionId]);

  return { session, isLoading, error, saveNotes, startSession, endSession, pauseSession };
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\hooks\useSession.ts"), $file21, $Utf8NoBom)
Write-Host "  OK  src/hooks/useSession.ts"

# ---------- src/hooks/useSessions.ts ----------
$file22 = @'
/**
 * src/hooks/useSessions.ts
 * Charge la liste des sessions et les stats globales depuis l'API.
 */
import { useState, useEffect } from 'react';
import api from '../lib/api';
import { Session } from '../types';

export function useSessions(engineerId?: string) {
  const [sessions, setSessions] = useState<Session[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    setIsLoading(true);

    const params = engineerId ? `?engineer_id=${engineerId}` : '';
    api.get(`/sessions${params}`)
      .then(({ data }) => { if (!cancelled) setSessions(data); })
      .catch((e) => { if (!cancelled) setError(e.response?.data?.message || 'Erreur réseau.'); })
      .finally(() => { if (!cancelled) setIsLoading(false); });

    return () => { cancelled = true; };
  }, [engineerId]);

  const createSession = async (engineerId: string, problem: string): Promise<Session> => {
    const { data } = await api.post('/sessions', { engineer_id: engineerId, problem });
    setSessions((prev) => [data, ...prev]);
    return data;
  };

  const deleteSession = async (id: string) => {
    await api.delete(`/sessions/${id}`);
    setSessions((prev) => prev.filter((s) => s.id !== id));
  };

  return { sessions, isLoading, error, createSession, deleteSession };
}

export function useGlobalStats() {
  const [stats, setStats] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    api.get('/sessions/stats/global')
      .then(({ data }) => setStats(data))
      .catch(() => {})
      .finally(() => setIsLoading(false));
  }, []);

  return { stats, isLoading };
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\hooks\useSessions.ts"), $file22, $Utf8NoBom)
Write-Host "  OK  src/hooks/useSessions.ts"

# ---------- src/hooks/useEngineers.ts ----------
$file23 = @'
/**
 * src/hooks/useEngineers.ts
 */
import { useState, useEffect } from 'react';
import api from '../lib/api';
import { Engineer } from '../types';

export function useEngineers() {
  const [engineers, setEngineers] = useState<Engineer[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    api.get('/engineers')
      .then(({ data }) => { if (!cancelled) setEngineers(data); })
      .catch((e) => { if (!cancelled) setError(e.response?.data?.message || 'Erreur réseau.'); })
      .finally(() => { if (!cancelled) setIsLoading(false); });
    return () => { cancelled = true; };
  }, []);

  const createEngineer = async (name: string, email: string, specialty: string) => {
    const { data } = await api.post('/engineers', { name, email, specialty });
    setEngineers((prev) => [data, ...prev]);
    return data;
  };

  return { engineers, isLoading, error, createEngineer };
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\hooks\useEngineers.ts"), $file23, $Utf8NoBom)
Write-Host "  OK  src/hooks/useEngineers.ts"

# ---------- src/lib/api.ts ----------
$file24 = @'
/**
 * src/lib/api.ts
 * Axios instance préconfigurée — ajoute automatiquement le JWT
 * et gère le refresh token transparent.
 */
import axios, { AxiosInstance, AxiosError } from 'axios';

const BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000/api';

const api: AxiosInstance = axios.create({
  baseURL: BASE_URL,
  headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
  withCredentials: false,
});

// ── Request interceptor : injecte le token JWT ────────────────────────────
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('finr_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// ── Response interceptor : refresh transparent + logout si 401 ───────────
let isRefreshing = false;
let queue: Array<(token: string) => void> = [];

api.interceptors.response.use(
  (res) => res,
  async (err: AxiosError) => {
    const original = err.config as any;

    if (err.response?.status === 401 && !original._retry) {
      original._retry = true;

      if (isRefreshing) {
        return new Promise((resolve) => {
          queue.push((token) => {
            original.headers.Authorization = `Bearer ${token}`;
            resolve(api(original));
          });
        });
      }

      isRefreshing = true;
      try {
        const { data } = await axios.post(`${BASE_URL}/auth/refresh`, {}, {
          headers: { Authorization: `Bearer ${localStorage.getItem('finr_token')}` },
        });
        const newToken = data.token;
        localStorage.setItem('finr_token', newToken);
        queue.forEach((cb) => cb(newToken));
        queue = [];
        original.headers.Authorization = `Bearer ${newToken}`;
        return api(original);
      } catch {
        localStorage.removeItem('finr_token');
        localStorage.removeItem('finr_user');
        window.location.href = '/';
      } finally {
        isRefreshing = false;
      }
    }

    return Promise.reject(err);
  }
);

export default api;

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\lib\api.ts"), $file24, $Utf8NoBom)
Write-Host "  OK  src/lib/api.ts"

# ---------- src/lib/echo.ts ----------
$file25 = @'
/**
 * src/lib/echo.ts
 * Instance Laravel Echo partagée pour les WebSockets (Reverb).
 * S'authentifie automatiquement avec le JWT stocké.
 */
import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

// Pusher-js est utilisé comme driver par Laravel Reverb
(window as any).Pusher = Pusher;

let echoInstance: Echo<any> | null = null;

export function getEcho(): Echo<any> {
  if (!echoInstance) {
    echoInstance = new Echo({
      broadcaster: 'reverb',
      key: process.env.REACT_APP_REVERB_KEY || 'finr-key',
      wsHost: process.env.REACT_APP_REVERB_HOST || 'localhost',
      wsPort: Number(process.env.REACT_APP_REVERB_PORT) || 8080,
      wssPort: Number(process.env.REACT_APP_REVERB_PORT) || 8080,
      forceTLS: false,
      enabledTransports: ['ws'],
      // Injecte le JWT pour les canaux privés (si besoin futur)
      authEndpoint: `${process.env.REACT_APP_API_URL || 'http://localhost:8000/api'}/broadcasting/auth`,
      auth: {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('finr_token') || ''}`,
        },
      },
    });
  }
  return echoInstance;
}

export function disconnectEcho(): void {
  echoInstance?.disconnect();
  echoInstance = null;
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\lib\echo.ts"), $file25, $Utf8NoBom)
Write-Host "  OK  src/lib/echo.ts"

# ---------- src/types/index.ts ----------
$file26 = @'
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

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "src\types\index.ts"), $file26, $Utf8NoBom)
Write-Host "  OK  src/types/index.ts"

Write-Host ""
Write-Host "Reinstallation terminee : 27 fichiers regeneres en UTF-8 propre." -ForegroundColor Green
Write-Host "Le serveur React va recharger automatiquement." -ForegroundColor Yellow