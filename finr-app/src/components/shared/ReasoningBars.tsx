import React from 'react';
import { reasoningColors, reasoningBgColors, reasoningTextColors } from '../../data/mockData';
import { ReasoningType, ReasoningPillar, REASONING_PILLAR_COLORS, REASONING_PILLAR_BG_COLORS, REASONING_PILLAR_TEXT_COLORS } from '../../types';

interface Bar { type: ReasoningType | ReasoningPillar; pct: number; isPillar?: boolean }

interface ReasoningBarsProps {
  data: Bar[];
  title?: string;
  groupByPillars?: boolean;
}

const ReasoningBars: React.FC<ReasoningBarsProps> = ({ data, title, groupByPillars = false }) => {
  const getColor = (type: ReasoningType | ReasoningPillar) => {
    if (groupByPillars && REASONING_PILLAR_COLORS[type as ReasoningPillar]) {
      return REASONING_PILLAR_COLORS[type as ReasoningPillar];
    }
    return reasoningColors[type as ReasoningType] || 'var(--purple)';
  };

  const getBgColor = (type: ReasoningType | ReasoningPillar) => {
    if (groupByPillars && REASONING_PILLAR_BG_COLORS[type as ReasoningPillar]) {
      return REASONING_PILLAR_BG_COLORS[type as ReasoningPillar];
    }
    return reasoningBgColors[type as ReasoningType] || '#EEECF8';
  };

  const getTextColor = (type: ReasoningType | ReasoningPillar) => {
    if (groupByPillars && REASONING_PILLAR_TEXT_COLORS[type as ReasoningPillar]) {
      return REASONING_PILLAR_TEXT_COLORS[type as ReasoningPillar];
    }
    return reasoningTextColors[type as ReasoningType] || 'var(--dark)';
  };

  return (
    <div>
      {title && (
        <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', letterSpacing: 0.5, textTransform: 'uppercase', marginBottom: 12 }}>
          {title}
        </div>
      )}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {data.map(b => {
          const color = getColor(b.type);
          const bgColor = getBgColor(b.type);
          const textColor = getTextColor(b.type);
          
          return (
            <div key={b.type} style={{ background: bgColor + '40', padding: '8px 12px', borderRadius: 8, border: `1px solid ${color}30` }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                <span style={{ fontSize: 13, color: textColor, fontWeight: 600 }}>{b.type}</span>
                <span style={{ fontSize: 13, fontWeight: 700, color: textColor }}>{b.pct}%</span>
              </div>
              <div style={{ background: '#EEECF8', borderRadius: 4, height: 6, overflow: 'hidden' }}>
                <div style={{
                  height: '100%',
                  width: `${b.pct}%`,
                  background: color,
                  borderRadius: 4,
                  transition: 'width 0.6s ease',
                }} />
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default ReasoningBars;

