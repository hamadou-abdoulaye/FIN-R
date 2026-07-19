import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useSession } from '../hooks/useSession';
import ReasoningBars from '../components/shared/ReasoningBars';
import { FlaskConical, Square, Lightbulb, FileText, Grid, List, PlayCircle, Mic, MicOff } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import api from '../lib/api';

// Extend Window interface for SpeechRecognition
declare global {
  interface Window {
    SpeechRecognition: any;
    webkitSpeechRecognition: any;
  }
}

type Tab = 'notes' | 'schema' | 'etapes' | 'idees';

const Workspace: React.FC = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuth();
  const { session, isLoading, saveNotes, startSession, endSession, pauseSession } = useSession(id);

  // Redirect researchers to session detail view
  useEffect(() => {
    if (user?.role === 'researcher' && session) {
      navigate(`/sessions/${session.id}`);
    }
  }, [user, session, navigate]);

  const [tab, setTab] = useState<Tab>('notes');
  const [notes, setNotes] = useState('');
  const [schema, setSchema] = useState('');
  const [etapes, setEtapes] = useState<string[]>(['Analyser les contraintes', 'Identifier les matériaux', 'Calculer les forces', 'Proposer des solutions']);
  const [idees, setIdees] = useState<string[]>(['Bride inox', 'Visserie M8', 'Profil aluminium', 'Joint EPDM']);
  const [newEtape, setNewEtape] = useState('');
  const [newIdee, setNewIdee] = useState('');
  const [elapsed, setElapsed] = useState(0);
  const [running, setRunning] = useState(false);
  const [isRecording, setIsRecording] = useState(false);
  const [recognition, setRecognition] = useState<any>(null);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);
  const lastDeltaRef = useRef('');
  const notesRef = useRef<HTMLTextAreaElement>(null);

  // Auto-end session when window/tab is closed
  useEffect(() => {
    const handleBeforeUnload = (e: BeforeUnloadEvent) => {
      console.log('beforeunload triggered', { running, status: session?.status });
      if (running && session?.status === 'active') {
        e.preventDefault();
        e.returnValue = 'Une session est en cours. Si vous quittez, la session sera terminée automatiquement.';
        endSession().catch(() => {});
      }
    };

    window.addEventListener('beforeunload', handleBeforeUnload);
    return () => window.removeEventListener('beforeunload', handleBeforeUnload);
  }, [running, session, endSession]);

  // Initialize speech recognition
  useEffect(() => {
    if (typeof window !== 'undefined' && (window.SpeechRecognition || window.webkitSpeechRecognition)) {
      const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
      const recognitionInstance = new SpeechRecognition();
      recognitionInstance.continuous = true;
      recognitionInstance.interimResults = true;
      recognitionInstance.lang = 'fr-FR';

      recognitionInstance.onresult = (event: any) => {
        let finalTranscript = '';

        for (let i = event.resultIndex; i < event.results.length; i++) {
          const transcript = event.results[i][0].transcript;
          if (event.results[i].isFinal) {
            finalTranscript += transcript;
          }
        }

        if (finalTranscript) {
          setNotes(prev => {
            const newText = prev + ' ' + finalTranscript;
            handleNotesChange(newText);
            return newText;
          });
        }
      };

      recognitionInstance.onerror = (event: any) => {
        console.error('Erreur reconnaissance vocale:', event.error);
        if (event.error !== 'no-speech') {
          setIsRecording(false);
        }
      };

      recognitionInstance.onend = () => {
        if (isRecording) {
          try {
            recognitionInstance.start();
          } catch (e) {
            console.error('Erreur redémarrage reconnaissance:', e);
            setIsRecording(false);
          }
        }
      };

      setRecognition(recognitionInstance);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Sync data from session when loaded
  useEffect(() => {
    if (session?.notes) setNotes(session.notes);
    if ((session as any)?.schema) setSchema((session as any).schema);
    if ((session as any)?.etapes) setEtapes((session as any).etapes);
    if ((session as any)?.idees) setIdees((session as any).idees);
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

  const toggleRecording = () => {
    if (!recognition) {
      alert('La reconnaissance vocale n\'est pas supportée par votre navigateur. Utilisez Chrome ou Edge.');
      return;
    }

    if (isRecording) {
      recognition.stop();
      setIsRecording(false);
    } else {
      try {
        recognition.start();
        setIsRecording(true);
      } catch (e) {
        console.error('Erreur démarrage reconnaissance:', e);
        alert('Impossible de démarrer la reconnaissance vocale. Veuillez réessayer.');
      }
    }
  };

  const handleNotesChange = (value: string) => {
    setNotes(value);
    lastDeltaRef.current = value;
    saveNotes(value);
  };

  const handleSchemaChange = (value: string) => {
    setSchema(value);
    saveSessionData({ schema: value });
  };

  const saveSessionData = async (data: any) => {
    try {
      await api.post(`/sessions/${id}/data`, data);
    } catch (e) {
      console.error('Erreur sauvegarde:', e);
    }
  };

  const addEtape = () => {
    if (!newEtape.trim()) return;
    const updated = [...etapes, newEtape.trim()];
    setEtapes(updated);
    setNewEtape('');
    saveSessionData({ etapes: updated });
  };

  const removeEtape = (index: number) => {
    const updated = etapes.filter((_, i) => i !== index);
    setEtapes(updated);
    saveSessionData({ etapes: updated });
  };

  const addIdee = () => {
    if (!newIdee.trim()) return;
    const updated = [...idees, newIdee.trim()];
    setIdees(updated);
    setNewIdee('');
    saveSessionData({ idees: updated });
  };

  const removeIdee = (index: number) => {
    const updated = idees.filter((_, i) => i !== index);
    setIdees(updated);
    saveSessionData({ idees: updated });
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
    return <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'linear-gradient(135deg, #F8FAFC 0%, #F1F5F9 50%, #EEF2FF 100%)', color: 'var(--gray)' }}>Chargement...</div>;
  }

  if (!session) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'linear-gradient(135deg, #F8FAFC 0%, #F1F5F9 50%, #EEF2FF 100%)', flexDirection: 'column', gap: 12 }}>
        <div style={{ color: 'var(--red-mid)', fontSize: 15, fontWeight: 600 }}>Session introuvable.</div>
        <div style={{ color: 'var(--gray)', fontSize: 13 }}>Vérifiez que la session #{id} existe bien et vous est assignée.</div>
        <button onClick={() => navigate('/')} style={{ marginTop: 8, color: 'var(--purple)', fontWeight: 600, fontSize: 13 }}>← Retour à la connexion</button>
      </div>
    );
  }

  const displaySession = session;

  return (
    <div style={{ minHeight: '100vh', background: 'linear-gradient(135deg, #EEF2FF 0%, #E0E7FF 25%, #F1F5F9 50%, #F8FAFC 75%, #EEF2FF 100%)', display: 'flex', flexDirection: 'column' }}>
      {/* Top bar */}
      <div style={{ background: 'rgba(255,255,255,0.98)', backdropFilter: 'blur(20px)', borderBottom: '1px solid var(--border)', padding: '0 32px', height: 72, display: 'flex', alignItems: 'center', gap: 20, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{ width: 36, height: 36, borderRadius: 10, background: 'linear-gradient(135deg, var(--purple) 0%, var(--purple-dark) 100%)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 2px 8px rgba(83,74,183,0.3)' }}>
            <FlaskConical size={18} color="white" />
          </div>
          <span style={{ fontWeight: 800, fontSize: 18, color: 'var(--purple)', letterSpacing: -0.5 }}>FIN-R</span>
        </div>
        <div style={{ width: 1, height: 20, background: 'var(--border)' }} />
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, fontSize: 13, color: 'var(--gray)' }}>
          <div style={{ width: 10, height: 10, borderRadius: '50%', background: running ? '#E24B4A' : '#94A3B8', boxShadow: running ? '0 0 8px rgba(226,75,74,0.4)' : 'none' }} />
          <span style={{ fontWeight: 700, color: 'var(--dark)', fontSize: 14 }}>Session #{String(displaySession.id || id || '').replace('ses', '')}</span>
          <span style={{ color: 'var(--gray-light)', fontSize: 11 }}>·</span>
          <span style={{ fontWeight: 500, fontSize: 13 }}>{displaySession.engineerName || displaySession.engineer_name}</span>
        </div>

        <div style={{ flex: 1 }} />
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, background: 'linear-gradient(135deg, var(--purple-light) 0%, #F0EDFE 100%)', padding: '8px 18px', borderRadius: 10, border: '1px solid #AFA9EC' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--purple)', letterSpacing: 0.5, textTransform: 'uppercase' }}>Durée</div>
          <div style={{ fontWeight: 800, fontSize: 20, color: 'var(--purple)', fontFamily: 'monospace', letterSpacing: 0.5 }}>
            ⏱ {formatTime(elapsed)}
          </div>
        </div>

        {!running ? (
          <button onClick={handleStart} style={{ display: 'flex', alignItems: 'center', gap: 6, background: 'linear-gradient(135deg, var(--green-mid) 0%, var(--green) 100%)', color: 'white', padding: '8px 16px', borderRadius: 8, fontWeight: 600, fontSize: 13, boxShadow: '0 2px 8px rgba(29,158,117,0.3)', transition: 'all 0.2s' }}>
            <PlayCircle size={14} /> Démarrer
          </button>
        ) : (
          <button onClick={handlePause} style={{ display: 'flex', alignItems: 'center', gap: 6, background: 'white', color: 'var(--red-mid)', padding: '8px 16px', borderRadius: 8, fontWeight: 600, fontSize: 13, border: '2px solid var(--red-mid)', transition: 'all 0.2s' }}>
            <Square size={14} /> Pause
          </button>
        )}
        <button onClick={handleEnd} style={{ background: 'linear-gradient(135deg, #E24B4A 0%, #C81E1E 100%)', color: 'white', padding: '8px 18px', borderRadius: 8, fontWeight: 600, fontSize: 13, boxShadow: '0 2px 8px rgba(226,75,74,0.3)', transition: 'all 0.2s' }}>
          Terminer
        </button>
      </div>

      <div style={{ display: 'flex', flex: 1 }}>
        {/* Editor */}
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: 28, gap: 18 }}>
          {/* Welcome header */}
          <div style={{ background: 'linear-gradient(135deg, var(--purple) 0%, var(--purple-dark) 100%)', borderRadius: 16, padding: '24px 28px', color: 'white', boxShadow: '0 4px 16px rgba(83,74,183,0.3)' }}>
            <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase', marginBottom: 6, opacity: 0.9 }}>Espace de travail</div>
            <div style={{ fontSize: 22, fontWeight: 800, marginBottom: 4 }}>Bienvenue, {displaySession.engineerName?.split(' ')[0] || 'Ingénieur'} !</div>
            <div style={{ fontSize: 13, opacity: 0.85, lineHeight: 1.5 }}>Analysez le problème et documentez votre raisonnement. Le système capturera vos événements cognitifs en temps réel.</div>
          </div>
          {/* Problem banner */}
          <div style={{ background: 'linear-gradient(135deg, #FEF3C7 0%, #FDE68A 100%)', borderRadius: 14, padding: '18px 24px', border: '1px solid #F59E0B', boxShadow: '0 4px 12px rgba(245,158,11,0.15)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
              <div style={{ width: 20, height: 20, borderRadius: '50%', background: 'var(--amber)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <span style={{ color: 'white', fontSize: 12, fontWeight: 700 }}>!</span>
              </div>
              <span style={{ fontSize: 10, fontWeight: 700, color: 'var(--amber)', letterSpacing: 0.5, textTransform: 'uppercase' }}>Problème de conception</span>
            </div>
            <p style={{ fontSize: 14, color: 'var(--dark)', lineHeight: 1.6, fontWeight: 500 }}>{displaySession.problem}</p>
          </div>

          {/* Tabs */}
          <div style={{ display: 'flex', gap: 6, background: 'var(--light-bg)', padding: 5, borderRadius: 12 }}>
            {tabs.map(t => (
              <button key={t.id} onClick={() => setTab(t.id)} style={{
                display: 'flex', alignItems: 'center', gap: 6,
                padding: '8px 16px', borderRadius: 8, fontSize: 13, fontWeight: tab === t.id ? 600 : 400,
                background: tab === t.id ? 'white' : 'transparent',
                color: tab === t.id ? 'var(--purple)' : 'var(--gray)',
                boxShadow: tab === t.id ? '0 2px 8px rgba(0,0,0,0.08)' : 'none',
                transition: 'all 0.2s',
              }}>
                {t.icon} {t.label}
              </button>
            ))}
          </div>

          {/* Editor area */}
          <div style={{ flex: 1, background: 'rgba(255,255,255,0.98)', backdropFilter: 'blur(16px)', borderRadius: 14, border: '1px solid var(--border)', padding: 24, display: 'flex', flexDirection: 'column', boxShadow: 'var(--shadow-lg)' }}>
            {tab === 'notes' && (
              <>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 }}>
                  <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--dark)' }}>Analyse du problème</div>
                  <button
                    onClick={toggleRecording}
                    style={{
                      display: 'flex', alignItems: 'center', gap: 6,
                      padding: '6px 14px', borderRadius: 8, fontSize: 12, fontWeight: 600,
                      background: isRecording ? 'var(--red-bg)' : 'var(--purple-light)',
                      color: isRecording ? 'var(--red)' : 'var(--purple)',
                      border: `1px solid ${isRecording ? 'rgba(220,38,38,0.2)' : '#AFA9EC'}`,
                      cursor: 'pointer', transition: 'all 0.2s',
                    }}
                  >
                    {isRecording ? <><MicOff size={14} /> Arrêter</> : <><Mic size={14} /> Vocal</>}
                  </button>
                </div>
                <textarea
                  ref={notesRef}
                  value={notes}
                  onChange={e => handleNotesChange(e.target.value)}
                  style={{ flex: 1, width: '100%', border: 'none', outline: 'none', resize: 'none', fontSize: 14, lineHeight: 1.7, color: 'var(--dark)', fontFamily: 'inherit', minHeight: 260 }}
                  placeholder="Commencez à noter votre analyse ici...&#10;&#10;💡 Astuce : Cliquez sur 'Vocal' pour dicter vos notes."
                />
                {isRecording && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '8px 12px', background: 'var(--red-bg)', borderRadius: 8, border: '1px solid rgba(220,38,38,0.2)', marginTop: 8 }}>
                    <div style={{ width: 8, height: 8, borderRadius: '50%', background: 'var(--red-mid)', animation: 'pulse 1.5s infinite' }} />
                    <span style={{ fontSize: 12, color: 'var(--red)', fontWeight: 600 }}>Enregistrement en cours...</span>
                    <style>{`@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.4; } }`}</style>
                  </div>
                )}
              </>
            )}
            {tab === 'schema' && (
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
                <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--dark)', marginBottom: 8 }}>Schéma de conception</div>
                <textarea
                  value={schema}
                  onChange={e => handleSchemaChange(e.target.value)}
                  style={{ flex: 1, width: '100%', border: 'none', outline: 'none', resize: 'none', fontSize: 14, lineHeight: 1.7, color: 'var(--dark)', fontFamily: 'inherit', minHeight: 260, background: 'transparent' }}
                  placeholder="Décrivez votre schéma de conception ici...&#10;&#10;Exemple :&#10;- Composant A : support principal&#10;- Composant B : système de fixation&#10;- Liaison : articulation pivot"
                />
              </div>
            )}
            {tab === 'etapes' && (
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
                <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--dark)', marginBottom: 12 }}>Étapes de résolution</div>
                <div style={{ flex: 1, overflowY: 'auto', marginBottom: 12 }}>
                  {etapes.map((etape, i) => (
                    <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 12px', background: 'var(--light-bg)', borderRadius: 8, marginBottom: 8 }}>
                      <div style={{ width: 24, height: 24, borderRadius: '50%', background: 'var(--purple-light)', color: 'var(--purple)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 12, fontWeight: 700, flexShrink: 0 }}>{i + 1}</div>
                      <span style={{ flex: 1, fontSize: 13 }}>{etape}</span>
                      <button onClick={() => removeEtape(i)} style={{ color: 'var(--red-mid)', fontSize: 18, lineHeight: 1, background: 'none', border: 'none', cursor: 'pointer', padding: '0 4px' }}>×</button>
                    </div>
                  ))}
                </div>
                <div style={{ display: 'flex', gap: 8 }}>
                  <input
                    value={newEtape}
                    onChange={e => setNewEtape(e.target.value)}
                    onKeyPress={e => e.key === 'Enter' && (e.preventDefault(), addEtape())}
                    placeholder="Nouvelle étape..."
                    style={{ flex: 1, padding: '10px 14px', border: '1px solid var(--border)', borderRadius: 8, fontSize: 13, outline: 'none' }}
                  />
                  <button onClick={addEtape} style={{ padding: '10px 18px', background: 'var(--purple)', color: 'white', borderRadius: 8, fontWeight: 600, fontSize: 13, border: 'none', cursor: 'pointer' }}>Ajouter</button>
                </div>
              </div>
            )}
            {tab === 'idees' && (
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
                <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--dark)', marginBottom: 12 }}>Idées</div>
                <div style={{ flex: 1, overflowY: 'auto', marginBottom: 12 }}>
                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
                    {idees.map((idee, i) => (
                      <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '8px 14px', background: 'var(--amber-bg)', color: 'var(--amber)', borderRadius: 8, fontSize: 13 }}>
                        <span>{idee}</span>
                        <button onClick={() => removeIdee(i)} style={{ color: 'var(--red-mid)', fontSize: 16, lineHeight: 1, background: 'none', border: 'none', cursor: 'pointer', padding: 0, fontWeight: 700 }}>×</button>
                      </div>
                    ))}
                  </div>
                </div>
                <div style={{ display: 'flex', gap: 8 }}>
                  <input
                    value={newIdee}
                    onChange={e => setNewIdee(e.target.value)}
                    onKeyPress={e => e.key === 'Enter' && (e.preventDefault(), addIdee())}
                    placeholder="Nouvelle idée..."
                    style={{ flex: 1, padding: '10px 14px', border: '1px solid var(--border)', borderRadius: 8, fontSize: 13, outline: 'none' }}
                  />
                  <button onClick={addIdee} style={{ padding: '10px 18px', background: 'var(--amber-mid)', color: 'white', borderRadius: 8, fontWeight: 600, fontSize: 13, border: 'none', cursor: 'pointer' }}>Ajouter</button>
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
        <div style={{ width: 320, background: 'rgba(255,255,255,0.98)', backdropFilter: 'blur(20px)', borderLeft: '1px solid var(--border)', padding: 24, display: 'flex', flexDirection: 'column', gap: 20, boxShadow: '-4px 0 24px rgba(0,0,0,0.06)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '10px 14px', background: running ? 'var(--green-bg)' : 'var(--light-bg)', borderRadius: 10, border: `1px solid ${running ? 'rgba(29,158,117,0.2)' : 'var(--border)'}` }}>
            <div style={{ width: 10, height: 10, borderRadius: '50%', background: running ? 'var(--green-mid)' : '#94A3B8', boxShadow: running ? '0 0 8px rgba(29,158,117,0.4)' : 'none' }} />
            <span style={{ fontSize: 13, fontWeight: 700, color: running ? 'var(--green)' : 'var(--gray)' }}>
              {running ? 'Analyse en cours' : 'En attente'}
            </span>
          </div>

          <ReasoningBars data={(displaySession.reasoning || []).map((r: any) => ({ type: r.type, pct: r.pct ?? r.percentage ?? 0 }))} title="Raisonnement détecté" />

          <div style={{ background: 'linear-gradient(135deg, var(--purple-light) 0%, #F0EDFE 100%)', borderRadius: 12, padding: 16, border: '1px solid #AFA9EC' }}>
            <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--purple)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 8 }}>Score créativité</div>
            <div style={{ fontSize: 28, fontWeight: 800, color: 'var(--purple)', display: 'flex', alignItems: 'baseline', gap: 4 }}>
              {displaySession.creativityScore ?? '—'}
              <span style={{ fontSize: 14, color: 'var(--gray)', fontWeight: 400 }}>/10</span>
            </div>
          </div>

          <div style={{ borderTop: '1px solid var(--border)', paddingTop: 14 }}>
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

          <div style={{ borderTop: '1px solid var(--border)', paddingTop: 14, marginTop: 'auto' }}>
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