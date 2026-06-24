import React from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { CheckCircle2, LogOut } from 'lucide-react';

/**
 * Page affichée à un ingénieur après avoir terminé sa session.
 * Il n'a pas accès au détail/analyse (réservé au chercheur),
 * juste une confirmation.
 */
const SessionCompleted: React.FC = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const { logout, user } = useAuth();

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  return (
    <div style={{
      minHeight: '100vh', background: 'linear-gradient(135deg, #1A1A2E 0%, #2D2B55 50%, #1A1A2E 100%)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      flexDirection: 'column', gap: 16, padding: 24, position: 'relative', overflow: 'hidden',
    }}>
      <div style={{ position: 'absolute', top: -150, right: -100, width: 400, height: 400, borderRadius: '50%', background: 'radial-gradient(circle, rgba(29,158,117,0.20) 0%, transparent 70%)' }} />
      <div style={{ position: 'absolute', bottom: -100, left: -80, width: 350, height: 350, borderRadius: '50%', background: 'radial-gradient(circle, rgba(83,74,183,0.20) 0%, transparent 70%)' }} />
      <div style={{
        width: 64, height: 64, borderRadius: '50%',
        background: 'var(--green-bg)', display: 'flex',
        alignItems: 'center', justifyContent: 'center',
      }}>
        <CheckCircle2 size={32} color="var(--green-mid)" />
      </div>
      <h1 style={{ color: 'white', fontSize: 22, fontWeight: 800 }}>Session terminée</h1>
      <p style={{ color: '#B0AECF', fontSize: 14, textAlign: 'center', maxWidth: 380 }}>
        Merci {user?.name?.split(' ')[0] || ''} ! Votre session #{id} a bien été enregistrée.
        Votre chercheur référent pourra consulter l'analyse complète de votre raisonnement.
      </p>
      <button
        onClick={handleLogout}
        style={{
          display: 'flex', alignItems: 'center', gap: 8,
          marginTop: 12, padding: '10px 22px', borderRadius: 8,
          background: 'var(--purple)', color: 'white', fontWeight: 600, fontSize: 14,
        }}
      >
        <LogOut size={15} /> Se déconnecter
      </button>
    </div>
  );
};

export default SessionCompleted;

