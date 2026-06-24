/**
 * src/lib/echo.ts
 * Instance Laravel Echo partagée pour les WebSockets (Reverb).
 * S'authentifie automatiquement avec le JWT stocké.
 */
import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

// Pusher-js est utilisé comme driver par Laravel Reverb
(window as any).Pusher = Pusher;

let echoInstance: Echo<any> | null = null;

export function getEcho(): Echo<any> {
  if (!echoInstance) {
    echoInstance = new Echo({
      broadcaster: 'reverb',
      key: process.env.REACT_APP_REVERB_KEY || 'finr-key',
      wsHost: process.env.REACT_APP_REVERB_HOST || 'localhost',
      wsPort: Number(process.env.REACT_APP_REVERB_PORT) || 8080,
      wssPort: Number(process.env.REACT_APP_REVERB_PORT) || 8080,
      forceTLS: false,
      enabledTransports: ['ws'],
      // Injecte le JWT pour les canaux privés (si besoin futur)
      authEndpoint: `${process.env.REACT_APP_API_URL || 'http://localhost:8000/api'}/broadcasting/auth`,
      auth: {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('finr_token') || ''}`,
        },
      },
    });
  }
  return echoInstance;
}

export function disconnectEcho(): void {
  echoInstance?.disconnect();
  echoInstance = null;
}

