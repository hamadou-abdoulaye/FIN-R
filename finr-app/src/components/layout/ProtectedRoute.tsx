import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

interface Props {
  children: React.ReactNode;
  roles?: Array<'researcher' | 'engineer'>;
}

const ProtectedRoute: React.FC<Props> = ({ children, roles }) => {
  const { isAuthenticated, isLoading, user } = useAuth();

  if (isLoading) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--dark)' }}>
        <div style={{ color: 'var(--purple-light)', fontSize: 14 }}>Chargement...</div>
      </div>
    );
  }

  if (!isAuthenticated) return <Navigate to="/" replace />;

  if (roles && user && !roles.includes(user.role)) {
    // Un utilisateur sans le bon rôle est renvoyé vers la page de connexion,
    // qui se chargera de le rediriger correctement selon son rôle réel
    // (dashboard pour chercheur, sa propre session pour ingénieur).
    return <Navigate to="/" replace />;
  }

  return <>{children}</>;
};

export default ProtectedRoute;

