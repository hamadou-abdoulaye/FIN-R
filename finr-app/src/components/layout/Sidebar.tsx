import React from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { LayoutDashboard, Users, PlayCircle, Brain, BarChart2, FileText, LogOut, FlaskConical } from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

const navItems = [
  { label: 'Dashboard',     icon: LayoutDashboard, path: '/dashboard' },
  { label: 'Ingénieurs',    icon: Users,           path: '/engineers' },
  { label: 'Sessions',      icon: PlayCircle,      path: '/sessions' },
  { label: 'Raisonnements', icon: Brain,           path: '/reasoning' },
  { label: 'Statistiques',  icon: BarChart2,       path: '/stats' },
  { label: 'Rapports',      icon: FileText,        path: '/reports' },
];

const Sidebar: React.FC = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const { user, logout } = useAuth();

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  return (
    <aside style={{ width: 'var(--sidebar-width)', background: 'linear-gradient(180deg, #FFFFFF 0%, #F8FAFC 100%)', borderRight: '1px solid var(--border)', display: 'flex', flexDirection: 'column', height: '100vh', position: 'fixed', top: 0, left: 0, zIndex: 100, backdropFilter: 'blur(10px)' }}>
      <div style={{ padding: '20px 20px 16px', borderBottom: '1px solid var(--border)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <div style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--purple)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <FlaskConical size={16} color="white" />
          </div>
          <span style={{ fontWeight: 800, fontSize: 18, color: 'var(--purple)', letterSpacing: -0.5 }}>
            FIN<span style={{ color: 'var(--purple-mid)' }}>-R</span>
          </span>
        </div>
        <div style={{ fontSize: 11, color: 'var(--gray)', marginTop: 4, marginLeft: 40 }}>
          {user?.name || 'Chercheur'} · ESP/UCAD
        </div>
      </div>

      <nav style={{ flex: 1, padding: '12px', display: 'flex', flexDirection: 'column', gap: 2 }}>
        {navItems.map(item => {
          const active = location.pathname === item.path;
          const Icon = item.icon;
          return (
            <button key={item.path} onClick={() => navigate(item.path)} style={{
              display: 'flex', alignItems: 'center', gap: 10,
              padding: '9px 12px', borderRadius: 8,
              background: active ? 'var(--purple-light)' : 'transparent',
              color: active ? 'var(--purple)' : 'var(--gray)',
              fontWeight: active ? 600 : 400, fontSize: 14,
              transition: 'all 0.15s', width: '100%', textAlign: 'left',
            }}>
              <Icon size={16} />{item.label}
            </button>
          );
        })}
      </nav>

      <div style={{ padding: '12px', borderTop: '1px solid var(--border)' }}>
        <button onClick={handleLogout} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '9px 12px', borderRadius: 8, color: 'var(--gray)', fontSize: 14, width: '100%' }}>
          <LogOut size={16} /> Déconnexion
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;

