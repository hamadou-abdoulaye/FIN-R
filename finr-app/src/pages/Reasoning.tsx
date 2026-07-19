import React, { useState } from 'react';
import { useSessions } from '../hooks/useSessions';
import { ReasoningType, ReasoningPillar, REASONING_PILLARS, REASONING_PILLAR_COLORS, REASONING_PILLAR_BG_COLORS, REASONING_PILLAR_TEXT_COLORS } from '../types';
import { Loader } from 'lucide-react';

const PILLARS: ReasoningPillar[] = ['Formel', 'Informel', 'Non formel'];

const PILLAR_DESCRIPTIONS: Record<ReasoningPillar, string> = {
  'Formel': "Logical: inferential, analytical, rule-based. Derives conclusions from fixed and known sets of premises. Linear, cartesian, systemic thinking. Well-defined, well-structured problems. Use well-defined premises to derive necessary and logical conclusions. Apply normative rules of inference. Make use of relevant information and consensus to support arguments or construct a well-informed decision. Involve prior knowledge, beliefs, and experience.",
  'Informel': "Illogical: informal, empirical, implicit, inferential intuition. Derive conclusions based on prior experience and beliefs. Non-linear, experiential thinking. Ill-defined, ill-structured, and open-ended problems. Unable [hard] to find justifiable premises that derive logical or illogical conclusions. Hardly traceable and has a high level of tacit knowledge. May partly be inferred from prior experience and expertise yet without clear justifications.",
  'Non formel': "Alogical, non-logical: neither logical nor illogical, non-inferential, unregulated, highly tacit, holistic intuition. Derives conclusions from unknown and unfixed premises. Non-linear, unexpected, unpredicted thinking.",
};

const Reasoning: React.FC = () => {
  const { sessions, isLoading } = useSessions();
  const [selectedPillar, setSelectedPillar] = useState<ReasoningPillar>('Formel');

  if (isLoading) return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: 300, gap: 10, color: 'var(--gray)' }}>
      <Loader size={18} style={{ animation: 'spin 1s linear infinite' }} /> Chargement...
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );

  const pillarTypes = REASONING_PILLARS[selectedPillar];
  
  const related = sessions.filter(s => {
    const dom = s.dominantReasoning || s.dominant_reasoning;
    return dom && pillarTypes.includes(dom as ReasoningType);
  });
  
  const avgScore = related.length
    ? (related.reduce((a, s) => a + (s.creativityScore ?? s.creativity_score ?? 0), 0) / related.length).toFixed(1)
    : '—';
  
  const avgPresence = sessions.length === 0 ? 0 : Math.round(
    sessions.reduce((acc, s) => {
      const pillarPct = (s.reasoning || [])
        .filter((r: any) => pillarTypes.includes(r.type))
        .reduce((sum: number, r: any) => sum + (r.pct ?? r.percentage ?? 0), 0);
      return acc + pillarPct;
    }, 0) / sessions.length
  );

  const col = REASONING_PILLAR_COLORS[selectedPillar];
  const bg = REASONING_PILLAR_BG_COLORS[selectedPillar];
  const txtCol = REASONING_PILLAR_TEXT_COLORS[selectedPillar];

  return (
    <div>
      <div style={{ marginBottom: 28 }}>
        <h1 style={{ fontSize: 24, fontWeight: 800, color: 'var(--dark)', marginBottom: 4 }}>Raisonnements</h1>
        <p style={{ fontSize: 14, color: 'var(--gray)' }}>Exploration des 3 piliers de raisonnement</p>
      </div>

      <div style={{ display: 'flex', gap: 10, marginBottom: 24, flexWrap: 'wrap' }}>
        {PILLARS.map(p => (
          <button key={p} onClick={() => setSelectedPillar(p)} style={{
            padding: '8px 18px', borderRadius: 20, fontWeight: 600, fontSize: 13,
            background: selectedPillar === p ? REASONING_PILLAR_BG_COLORS[p] : 'white',
            color: selectedPillar === p ? REASONING_PILLAR_TEXT_COLORS[p] : 'var(--gray)',
            border: `2px solid ${selectedPillar === p ? REASONING_PILLAR_COLORS[p] : 'var(--border)'}`,
            transition: 'all 0.15s',
          }}>{p}</button>
        ))}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20 }}>
        <div style={{ background: bg, borderRadius: 'var(--radius)', padding: 24, border: `1px solid ${col}40`, gridColumn: '1 / -1' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 12 }}>
            <div style={{ width: 16, height: 16, borderRadius: '50%', background: col }} />
            <span style={{ fontSize: 20, fontWeight: 800, color: txtCol }}>{selectedPillar}</span>
          </div>
          <p style={{ fontSize: 15, color: 'var(--dark)', lineHeight: 1.7 }}>{PILLAR_DESCRIPTIONS[selectedPillar]}</p>
        </div>

        <div style={{ background: 'rgba(255,255,255,0.95)', backdropFilter: 'blur(16px)', borderRadius: 'var(--radius)', padding: 24, border: '1px solid var(--border)', boxShadow: 'var(--shadow-xl)' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 16 }}>Statistiques</div>
          <div style={{ display: 'flex', gap: 32 }}>
            <div><div style={{ fontSize: 32, fontWeight: 800, color: col }}>{related.length}</div><div style={{ fontSize: 12, color: 'var(--gray)' }}>sessions associées</div></div>
            <div><div style={{ fontSize: 32, fontWeight: 800, color: 'var(--dark)' }}>{avgScore}</div><div style={{ fontSize: 12, color: 'var(--gray)' }}>créativité moy.</div></div>
            <div><div style={{ fontSize: 32, fontWeight: 800, color: 'var(--dark)' }}>{avgPresence}%</div><div style={{ fontSize: 12, color: 'var(--gray)' }}>présence moyenne</div></div>
          </div>
        </div>

        <div style={{ background: 'rgba(255,255,255,0.95)', backdropFilter: 'blur(16px)', borderRadius: 'var(--radius)', padding: 24, border: '1px solid var(--border)', boxShadow: 'var(--shadow-xl)' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 14 }}>Sessions associées</div>
          {related.length === 0
            ? <p style={{ fontSize: 13, color: 'var(--gray)' }}>Aucune session avec ce pilier dominant.</p>
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
            Présence du pilier « {selectedPillar} » dans chaque session
          </div>
          {sessions.length === 0
            ? <p style={{ fontSize: 13, color: 'var(--gray)' }}>Aucune donnée.</p>
            : sessions.map(s => {
                const pillarPct = (s.reasoning || [])
                  .filter((r: any) => pillarTypes.includes(r.type))
                  .reduce((sum: number, r: any) => sum + (r.pct ?? r.percentage ?? 0), 0);
                const name = s.engineerName || s.engineer_name || '—';
                return (
                  <div key={s.id} style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 10 }}>
                    <div style={{ width: 120, fontSize: 13, fontWeight: 500, flexShrink: 0 }}>{name.split(' ')[0]}</div>
                    <div style={{ flex: 1, background: '#EEECF8', borderRadius: 4, height: 8, overflow: 'hidden' }}>
                      <div style={{ height: '100%', width: `${Math.min(pillarPct, 100)}%`, background: col, borderRadius: 4, transition: 'width 0.6s ease' }} />
                    </div>
                    <div style={{ width: 40, textAlign: 'right', fontSize: 13, fontWeight: 600, color: 'var(--gray)' }}>{Math.min(pillarPct, 100)}%</div>
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