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

        <div style={{ background: 'rgba(255,255,255,0.95)', backdropFilter: 'blur(16px)', borderRadius: 'var(--radius)', padding: 24, border: '1px solid var(--border)', boxShadow: 'var(--shadow-xl)' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 16 }}>Statistiques</div>
          <div style={{ display: 'flex', gap: 32 }}>
            <div><div style={{ fontSize: 32, fontWeight: 800, color: col }}>{related.length}</div><div style={{ fontSize: 12, color: 'var(--gray)' }}>sessions dominantes</div></div>
            <div><div style={{ fontSize: 32, fontWeight: 800, color: 'var(--dark)' }}>{avgScore}</div><div style={{ fontSize: 12, color: 'var(--gray)' }}>créativité moy.</div></div>
            <div><div style={{ fontSize: 32, fontWeight: 800, color: 'var(--dark)' }}>{avgPresence}%</div><div style={{ fontSize: 12, color: 'var(--gray)' }}>présence moyenne</div></div>
          </div>
        </div>

        <div style={{ background: 'rgba(255,255,255,0.95)', backdropFilter: 'blur(16px)', borderRadius: 'var(--radius)', padding: 24, border: '1px solid var(--border)', boxShadow: 'var(--shadow-xl)' }}>
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

        <div style={{ background: 'rgba(255,255,255,0.95)', backdropFilter: 'blur(16px)', borderRadius: 'var(--radius)', padding: 24, border: '1px solid var(--border)', boxShadow: 'var(--shadow-xl)', gridColumn: '1 / -1' }}>
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

