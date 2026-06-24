import React, { useState } from 'react';
import { useSessions } from '../hooks/useSessions';
import { ReasoningPill } from '../components/shared/Pill';
import { Download, FileText, Calendar, User, Brain, Star, Zap, Loader } from 'lucide-react';
import api from '../lib/api';

const Reports: React.FC = () => {
  const { sessions, isLoading } = useSessions();
  const [selectedId, setSelectedId] = useState<string | null>(null);

  React.useEffect(() => {
    if (sessions.length > 0 && !selectedId) setSelectedId(String(sessions[0].id));
  }, [sessions, selectedId]);

  const session = sessions.find(s => String(s.id) === selectedId);

  const handleDownloadPdf = async () => {
    if (!session) return;
    try {
      const res = await api.get(`/sessions/${session.id}/pdf`, { responseType: 'blob' });
      const url = window.URL.createObjectURL(new Blob([res.data], { type: 'application/pdf' }));
      const a = document.createElement('a');
      a.href = url;
      a.download = `rapport-session-${session.id}.pdf`;
      document.body.appendChild(a);
      a.click();
      a.remove();
      window.URL.revokeObjectURL(url);
    } catch (e) {
      console.error('Erreur téléchargement PDF', e);
      alert('Impossible de générer le PDF pour le moment.');
    }
  };

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
        <div style={{ background: 'rgba(255,255,255,0.85)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', padding: 16, border: '1px solid var(--border)', boxShadow: 'var(--shadow)', height: 'fit-content' }}>
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
            <div style={{ background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)', overflow: 'hidden' }}>
              {/* Header */}
              <div style={{ background: 'var(--dark)', padding: '20px 28px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <div style={{ color: 'var(--purple-light)', fontSize: 11, fontWeight: 700, letterSpacing: 1, textTransform: 'uppercase', marginBottom: 4 }}>FIN-R · Rapport de session</div>
                  <div style={{ color: 'white', fontSize: 20, fontWeight: 800 }}>{name}</div>
                  <div style={{ color: '#B0AECF', fontSize: 13, marginTop: 2 }}>{session.date} · {session.duration || '—'}</div>
                </div>
                <button onClick={handleDownloadPdf} style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--purple)', color: 'white', padding: '10px 18px', borderRadius: 8, fontWeight: 600, fontSize: 14 }}>
                  <Download size={15} /> Télécharger le PDF
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
                    <div key={item.label} style={{ background: 'linear-gradient(135deg, #F8FAFC 0%, #F1F5F9 100%)', borderRadius: 8, padding: '12px 14px', border: '1px solid var(--border)' }}>
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

