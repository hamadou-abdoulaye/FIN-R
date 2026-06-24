import React from 'react';

const LoginAnimation: React.FC = () => {
  return (
    <div style={{ position: 'relative', width: '100%', maxWidth: 480, aspectRatio: '1', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <svg viewBox="0 0 400 400" style={{ width: '100%', height: '100%', filter: 'drop-shadow(0 10px 40px rgba(83,74,183,0.3))' }}>
        {/* Cercles concentriques animés */}
        <circle cx="200" cy="200" r="180" fill="none" stroke="rgba(83,74,183,0.1)" strokeWidth="1">
          <animate attributeName="r" values="180;190;180" dur="4s" repeatCount="indefinite" />
          <animate attributeName="opacity" values="0.3;0.1;0.3" dur="4s" repeatCount="indefinite" />
        </circle>
        <circle cx="200" cy="200" r="140" fill="none" stroke="rgba(127,119,221,0.15)" strokeWidth="1.5">
          <animate attributeName="r" values="140;150;140" dur="3.5s" repeatCount="indefinite" />
        </circle>
        <circle cx="200" cy="200" r="100" fill="none" stroke="rgba(83,74,183,0.2)" strokeWidth="2">
          <animate attributeName="r" values="100;110;100" dur="3s" repeatCount="indefinite" />
        </circle>

        {/* Hexagone central - représentation structure moléculaire/raisonnement */}
        <g transform="translate(200,200)">
          <animateTransform attributeName="transform" type="rotate" values="0;360" dur="60s" repeatCount="indefinite" />
          {[0,60,120,180,240,300].map((angle, i) => {
            const rad = (angle * Math.PI) / 180;
            const x = Math.cos(rad) * 70;
            const y = Math.sin(rad) * 70;
            return (
              <g key={i}>
                <circle cx={x} cy={y} r="8" fill={i % 2 === 0 ? '#534AB7' : '#7F77DD'}>
                  <animate attributeName="r" values="8;10;8" dur="2s" begin={`${i * 0.3}s`} repeatCount="indefinite" />
                </circle>
                <line x1="0" y1="0" x2={x} y2={y} stroke="rgba(83,74,183,0.3)" strokeWidth="1.5">
                  <animate attributeName="stroke-opacity" values="0.3;0.6;0.3" dur="2s" begin={`${i * 0.3}s`} repeatCount="indefinite" />
                </line>
              </g>
            );
          })}
          <circle cx="0" cy="0" r="12" fill="#534AB7">
            <animate attributeName="r" values="12;14;12" dur="2s" repeatCount="indefinite" />
          </circle>
        </g>

        {/* Orbites elliptiques */}
        <ellipse cx="200" cy="200" rx="160" ry="60" fill="none" stroke="rgba(127,119,221,0.2)" strokeWidth="1" transform="rotate(-20 200 200)">
          <animateTransform attributeName="transform" type="rotate" values="-20;340" dur="20s" repeatCount="indefinite" />
        </ellipse>
        <ellipse cx="200" cy="200" rx="160" ry="60" fill="none" stroke="rgba(83,74,183,0.15)" strokeWidth="1" transform="rotate(40 200 200)">
          <animateTransform attributeName="transform" type="rotate" values="40;400" dur="25s" repeatCount="indefinite" />
        </ellipse>

        {/* Points flottants - représentation données/neurones */}
        {[
          { x: 120, y: 150, delay: 0 }, { x: 280, y: 180, delay: 0.5 }, { x: 150, y: 280, delay: 1 },
          { x: 260, y: 250, delay: 1.5 }, { x: 180, y: 120, delay: 2 }, { x: 240, y: 300, delay: 2.5 },
        ].map((point, i) => (
          <circle key={i} cx={point.x} cy={point.y} r="4" fill="#7F77DD">
            <animate attributeName="cy" values={`${point.y};${point.y - 10};${point.y}`} dur="3s" begin={`${point.delay}s`} repeatCount="indefinite" />
            <animate attributeName="opacity" values="0.4;0.8;0.4" dur="3s" begin={`${point.delay}s`} repeatCount="indefinite" />
          </circle>
        ))}

        {/* Texte FIN-R stylisé */}
        <text x="200" y="360" textAnchor="middle" fill="rgba(83,74,183,0.6)" fontSize="14" fontWeight="700" letterSpacing="4">
          FIN-R
          <animate attributeName="opacity" values="0.5;1;0.5" dur="3s" repeatCount="indefinite" />
        </text>
      </svg>
    </div>
  );
};

export default LoginAnimation;