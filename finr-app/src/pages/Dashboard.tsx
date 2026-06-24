import React from 'react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import { useSessions, useGlobalStats } from '../hooks/useSessions';
import { useEngineers } from '../hooks/useEngineers';
import { reasoningColors } from '../data/mockData';
import MetricCard from '../components/dashboard/MetricCard';
import SessionList from '../components/dashboard/SessionList';
import ReasoningBars from '../components/shared/ReasoningBars';
import { MetricCardSkeleton, ChartSkeleton, TableSkeleton } from '../components/Skeleton';
import { ReasoningType } from '../types';
import { PlusCircle } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const MONTHS = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'];

const Dashboard: React.FC = () => {
  const navigate = useNavigate();
  const { sessions, isLoading: loadingSessions } = useSessions();
  const { engineers, isLoading: loadingEngineers } = useEngineers();
  const { stats } = useGlobalStats();

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
    <div>
      <div style={{ display: 'flex', gap: 16, marginBottom: 24 }}>
        {Array.from({ length: 4 }).map((_, i) => <MetricCardSkeleton key={i} />)}
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 20, marginBottom: 20 }}>
        <ChartSkeleton />
        <ChartSkeleton />
        <ChartSkeleton />
      </div>
      <TableSkeleton rows={4} />
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
        <MetricCard label="Sessions totales" value={String(stats?.total_sessions ?? sessions.length)} sub={`${stats?.completed_sessions ?? 0} terminées`} subPositive={true} color="var(--purple)" />
        <MetricCard label="Ingénieurs suivis" value={String(engineers.length)} sub={`${engineers.length} enregistrés`} color="var(--blue-mid)" />
        <MetricCard label="Raisonnement dominant" value={dominantReasoning} sub={`${reasoningDist[0]?.pct ?? 0}% des sessions`} accent={true} color="var(--amber-mid)" />
        <MetricCard label="Score créativité moy." value={avgCreativity === '—' ? '—' : `${avgCreativity}/10`} sub="moyenne générale" subPositive={true} color="var(--green-mid)" />
      </div>

      {/* Main grid */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 20, marginBottom: 20 }}>
        <div style={{ background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)' }}>
          <SessionList sessions={sessions} limit={4} />
          <button onClick={() => navigate('/sessions')} style={{ marginTop: 12, fontSize: 13, color: 'var(--purple)', fontWeight: 600, width: '100%', textAlign: 'center', padding: '6px 0' }}>
            Voir toutes les sessions →
          </button>
        </div>

        <div style={{ background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)' }}>
          {reasoningDist.length > 0
            ? <ReasoningBars data={reasoningDist} title="Répartition des raisonnements" />
            : <p style={{ fontSize: 13, color: 'var(--gray)', textAlign: 'center', marginTop: 40 }}>Aucune donnée disponible</p>
          }
        </div>

        <div style={{ background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)' }}>
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
      <div style={{ background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(12px)', borderRadius: 'var(--radius)', padding: 20, border: '1px solid var(--border)', boxShadow: 'var(--shadow-lg)' }}>
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

