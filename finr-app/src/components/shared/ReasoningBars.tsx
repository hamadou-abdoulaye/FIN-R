import React from 'react';
import { reasoningColors } from '../../data/mockData';
import { ReasoningType } from '../../types';

interface Bar { type: ReasoningType; pct: number }

interface ReasoningBarsProps {
  data: Bar[];
  title?: string;
}

const ReasoningBars: React.FC<ReasoningBarsProps> = ({ data, title }) => (
  <div>
    {title && (
      <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 12 }}>
        {title}
      </div>
    )}
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      {data.map(b => (
        <div key={b.type}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4 }}>
            <span style={{ fontSize: 13, color: 'var(--gray)' }}>{b.type}</span>
            <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--dark)' }}>{b.pct}%</span>
          </div>
          <div style={{ background: '#EEECF8', borderRadius: 4, height: 6, overflow: 'hidden' }}>
            <div style={{
              height: '100%',
              width: `${b.pct}%`,
              background: reasoningColors[b.type] || 'var(--purple)',
              borderRadius: 4,
              transition: 'width 0.6s ease',
            }} />
          </div>
        </div>
      ))}
    </div>
  </div>
);

export default ReasoningBars;

