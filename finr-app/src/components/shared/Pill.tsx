import React from 'react';
import { reasoningBgColors, reasoningTextColors } from '../../data/mockData';
import { ReasoningType } from '../../types';

interface PillProps {
  type: ReasoningType;
  size?: 'sm' | 'md';
}

export const ReasoningPill: React.FC<PillProps> = ({ type, size = 'md' }) => {
  const bg = reasoningBgColors[type] || '#f0f0f0';
  const color = reasoningTextColors[type] || '#333';
  return (
    <span style={{
      display: 'inline-block',
      background: bg,
      color,
      borderRadius: 20,
      padding: size === 'sm' ? '2px 8px' : '4px 12px',
      fontSize: size === 'sm' ? 11 : 12,
      fontWeight: 600,
      whiteSpace: 'nowrap',
    }}>
      {type}
    </span>
  );
};

interface AvatarProps {
  initials: string;
  size?: number;
}

export const Avatar: React.FC<AvatarProps> = ({ initials, size = 36 }) => (
  <div style={{
    width: size, height: size, borderRadius: '50%',
    background: 'var(--purple-light)',
    color: 'var(--purple-dark)',
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    fontSize: size * 0.36, fontWeight: 700, flexShrink: 0,
  }}>
    {initials}
  </div>
);

