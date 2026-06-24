import React from 'react';

interface MetricCardProps {
  label: string;
  value: string;
  sub: string;
  subPositive?: boolean;
  accent?: boolean;
  color?: string;
}

const MetricCard: React.FC<MetricCardProps> = ({ label, value, sub, subPositive, accent, color }) => {
  const iconColor = color || (accent ? 'var(--purple)' : 'var(--dark)');
  const bgGradient = color ? `linear-gradient(135deg, ${color}15 0%, ${color}08 100%)` : 'white';
  const borderColor = color ? `${color}30` : 'var(--border)';
  
  return (
    <div style={{
      background: bgGradient,
      border: `1px solid ${borderColor}`,
      borderRadius: 'var(--radius)',
      padding: '18px 22px',
      boxShadow: 'var(--shadow-lg)',
      flex: 1,
      minWidth: 0,
      transition: 'all 0.2s',
    }}>
      <div style={{ fontSize: 12, color: 'var(--gray)', marginBottom: 8, fontWeight: 500 }}>{label}</div>
      <div style={{
        fontSize: accent ? 22 : 30,
        fontWeight: 800,
        color: iconColor,
        lineHeight: 1.1,
        marginBottom: 6,
      }}>
        {value}
      </div>
      <div style={{
        fontSize: 12,
        fontWeight: 500,
        color: subPositive !== undefined
          ? (subPositive ? 'var(--green-mid)' : 'var(--red-mid)')
          : 'var(--gray)',
      }}>
        {sub}
      </div>
    </div>
  );
};

export default MetricCard;

