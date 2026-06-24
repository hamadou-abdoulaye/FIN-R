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
    <div style={{ background: 'rgba(255,255,255,0.95)', backdropFilter: 'blur(16px)', borderRadius: 'var(--radius)', padding: 24, border: '1px solid var(--border)', boxShadow: 'var(--shadow-xl)' }}>
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
      <div style={{ background: 'rgba(255,255,255,0.95)', backdropFilter: 'blur(16px)', borderRadius: 'var(--radius)', padding: 24, border: '1px solid var(--border)', boxShadow: 'var(--shadow-xl)' }}>
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

