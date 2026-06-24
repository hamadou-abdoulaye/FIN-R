import React from 'react';

interface ConfirmDialogProps {
  isOpen: boolean;
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  onConfirm: () => void;
  onCancel: () => void;
  type?: 'danger' | 'warning' | 'info';
}

const ConfirmDialog: React.FC<ConfirmDialogProps> = ({
  isOpen,
  title,
  message,
  confirmText = 'Confirmer',
  cancelText = 'Annuler',
  onConfirm,
  onCancel,
  type = 'danger',
}) => {
  if (!isOpen) return null;

  const colors = {
    danger: { bg: 'var(--red-bg)', border: 'rgba(220,38,38,0.3)', text: 'var(--red)', button: 'var(--red-mid)' },
    warning: { bg: 'var(--amber-bg)', border: 'rgba(245,158,11,0.3)', text: 'var(--amber)', button: 'var(--amber-mid)' },
    info: { bg: 'var(--blue-bg)', border: 'rgba(59,130,246,0.3)', text: 'var(--blue)', button: 'var(--blue-mid)' },
  };

  const c = colors[type];

  return (
    <div style={{
      position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', zIndex: 9999,
      display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20,
      backdropFilter: 'blur(4px)',
    }} onClick={onCancel}>
      <div style={{
        background: 'white', borderRadius: 20, padding: 28, maxWidth: 420, width: '100%',
        boxShadow: 'var(--shadow-xl)', border: `1px solid ${c.border}`,
        animation: 'slideIn 0.2s ease',
      }} onClick={e => e.stopPropagation()}>
        <div style={{
          width: 48, height: 48, borderRadius: '50%', background: c.bg,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          margin: '0 auto 16px', border: `2px solid ${c.border}`,
        }}>
          <span style={{ fontSize: 24, color: c.text }}>⚠</span>
        </div>
        <h3 style={{ fontSize: 18, fontWeight: 700, color: 'var(--dark)', marginBottom: 8, textAlign: 'center' }}>
          {title}
        </h3>
        <p style={{ fontSize: 14, color: 'var(--gray)', textAlign: 'center', lineHeight: 1.6, marginBottom: 24 }}>
          {message}
        </p>
        <div style={{ display: 'flex', gap: 12, justifyContent: 'center' }}>
          <button
            onClick={onCancel}
            style={{
              padding: '10px 24px', borderRadius: 10, fontSize: 14, fontWeight: 600,
              background: 'white', color: 'var(--gray)',
              border: '1px solid var(--border)',
              transition: 'all 0.2s',
            }}
          >
            {cancelText}
          </button>
          <button
            onClick={onConfirm}
            style={{
              padding: '10px 24px', borderRadius: 10, fontSize: 14, fontWeight: 600,
              background: c.button, color: 'white',
              boxShadow: `0 4px 12px ${c.border}`,
              transition: 'all 0.2s',
            }}
          >
            {confirmText}
          </button>
        </div>
      </div>
      <style>{`
        @keyframes slideIn {
          from { transform: scale(0.9); opacity: 0; }
          to { transform: scale(1); opacity: 1; }
        }
      `}</style>
    </div>
  );
};

export default ConfirmDialog;