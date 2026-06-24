import React from 'react';

interface SkeletonProps {
  width?: string | number;
  height?: string | number;
  borderRadius?: string | number;
  style?: React.CSSProperties;
}

export const Skeleton: React.FC<SkeletonProps> = ({
  width = '100%',
  height = 20,
  borderRadius = 8,
  style = {},
}) => (
  <div
    style={{
      width,
      height,
      borderRadius,
      background: 'linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%)',
      backgroundSize: '200% 100%',
      animation: 'skeleton-loading 1.5s infinite',
      ...style,
    }}
  />
);

export const CardSkeleton: React.FC = () => (
  <div style={{
    background: 'rgba(255,255,255,0.95)',
    borderRadius: 'var(--radius)',
    padding: 20,
    border: '1px solid var(--border)',
    boxShadow: 'var(--shadow)',
  }}>
    <Skeleton width="60%" height={24} borderRadius={6} style={{ marginBottom: 12 }} />
    <Skeleton width="100%" height={16} borderRadius={4} style={{ marginBottom: 8 }} />
    <Skeleton width="80%" height={16} borderRadius={4} style={{ marginBottom: 8 }} />
    <Skeleton width="40%" height={14} borderRadius={4} />
  </div>
);

export const TableSkeleton: React.FC<{ rows?: number }> = ({ rows = 5 }) => (
  <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
    {Array.from({ length: rows }).map((_, i) => (
      <div key={i} style={{ display: 'flex', gap: 16, alignItems: 'center', padding: '12px 0', borderBottom: '1px solid var(--border)' }}>
        <Skeleton width={40} height={40} borderRadius="50%" />
        <div style={{ flex: 1 }}>
          <Skeleton width="30%" height={16} borderRadius={4} style={{ marginBottom: 6 }} />
          <Skeleton width="50%" height={14} borderRadius={4} />
        </div>
        <Skeleton width={80} height={32} borderRadius={6} />
      </div>
    ))}
  </div>
);

export const MetricCardSkeleton: React.FC = () => (
  <div style={{
    background: 'white',
    border: '1px solid var(--border)',
    borderRadius: 'var(--radius)',
    padding: '18px 22px',
    boxShadow: 'var(--shadow)',
    flex: 1,
  }}>
    <Skeleton width="70%" height={14} borderRadius={4} style={{ marginBottom: 10 }} />
    <Skeleton width="40%" height={32} borderRadius={6} style={{ marginBottom: 6 }} />
    <Skeleton width="60%" height={12} borderRadius={4} />
  </div>
);

export const ChartSkeleton: React.FC = () => (
  <div style={{
    background: 'rgba(255,255,255,0.95)',
    borderRadius: 'var(--radius)',
    padding: 24,
    border: '1px solid var(--border)',
    boxShadow: 'var(--shadow)',
  }}>
    <Skeleton width="50%" height={14} borderRadius={4} style={{ marginBottom: 20 }} />
    <Skeleton width="100%" height={200} borderRadius={8} />
  </div>
);

export default Skeleton;