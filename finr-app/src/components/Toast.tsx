import React, { useState, useCallback, createContext, useContext } from 'react';

type ToastType = 'success' | 'error' | 'info' | 'warning';

interface Toast {
  id: string;
  message: string;
  type: ToastType;
}

interface ToastContextValue {
  showToast: (message: string, type?: ToastType) => void;
}

const ToastContext = createContext<ToastContextValue | null>(null);

export const useToast = () => {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error('useToast must be used within ToastProvider');
  return ctx;
};

export const ToastProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const showToast = useCallback((message: string, type: ToastType = 'info') => {
    const id = Date.now().toString();
    setToasts(prev => [...prev, { id, message, type }]);
    setTimeout(() => {
      setToasts(prev => prev.filter(t => t.id !== id));
    }, 4000);
  }, []);

  const removeToast = (id: string) => {
    setToasts(prev => prev.filter(t => t.id !== id));
  };

  const colors: Record<ToastType, { bg: string; border: string; text: string; icon: string }> = {
    success: { bg: 'var(--green-bg)', border: 'rgba(29,158,117,0.3)', text: 'var(--green)', icon: '✓' },
    error: { bg: 'var(--red-bg)', border: 'rgba(220,38,38,0.3)', text: 'var(--red)', icon: '✕' },
    warning: { bg: 'var(--amber-bg)', border: 'rgba(245,158,11,0.3)', text: 'var(--amber)', icon: '⚠' },
    info: { bg: 'var(--blue-bg)', border: 'rgba(59,130,246,0.3)', text: 'var(--blue)', icon: 'ℹ' },
  };

  return (
    <ToastContext.Provider value={{ showToast }}>
      {children}
      <div style={{
        position: 'fixed', top: 20, right: 20, zIndex: 9999,
        display: 'flex', flexDirection: 'column', gap: 10, maxWidth: 400,
      }}>
        {toasts.map(toast => {
          const c = colors[toast.type];
          return (
            <div key={toast.id} style={{
              background: c.bg,
              border: `1px solid ${c.border}`,
              borderRadius: 12,
              padding: '14px 18px',
              boxShadow: 'var(--shadow-xl)',
              display: 'flex',
              alignItems: 'center',
              gap: 12,
              animation: 'slideIn 0.3s ease',
              backdropFilter: 'blur(12px)',
            }}>
              <div style={{
                width: 24, height: 24, borderRadius: '50%',
                background: c.text, color: 'white',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 14, fontWeight: 700, flexShrink: 0,
              }}>
                {c.icon}
              </div>
              <div style={{ flex: 1, fontSize: 14, color: c.text, fontWeight: 500 }}>{toast.message}</div>
              <button onClick={() => removeToast(toast.id)} style={{
                color: c.text, fontSize: 18, lineHeight: 1,
                background: 'none', border: 'none', cursor: 'pointer', padding: 0,
              }}>
                ×
              </button>
            </div>
          );
        })}
      </div>
      <style>{`
        @keyframes slideIn {
          from { transform: translateX(100%); opacity: 0; }
          to { transform: translateX(0); opacity: 1; }
        }
      `}</style>
    </ToastContext.Provider>
  );
};