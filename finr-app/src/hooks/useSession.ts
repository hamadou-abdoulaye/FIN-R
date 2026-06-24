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
          notes: payload.notes ?? prev.notes,
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

    // Debounce: send to API after 1.5 s of inactivity for near-real-time sync
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
    }, 1500);
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

