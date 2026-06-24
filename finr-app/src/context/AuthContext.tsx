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

