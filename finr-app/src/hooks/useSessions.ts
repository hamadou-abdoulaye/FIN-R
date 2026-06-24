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

