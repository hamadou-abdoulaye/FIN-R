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

  const createEngineer = async (name: string, email: string, specialty: string, role: 'engineer' | 'researcher' = 'engineer') => {
    const { data } = await api.post('/engineers', { name, email, specialty, role });
    setEngineers((prev) => [data, ...prev]);
    return data;
  };

  const deleteEngineer = async (id: string) => {
    await api.delete(`/engineers/${id}`);
    setEngineers((prev) => prev.filter((e) => String(e.id) !== id));
  };

  return { engineers, isLoading, error, createEngineer, deleteEngineer };
}

