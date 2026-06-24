import React, { Suspense, lazy } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { ToastProvider } from './components/Toast';
import ProtectedRoute from './components/layout/ProtectedRoute';
import AppLayout from './components/layout/AppLayout';

import Login from './pages/Login';

// Lazy loading des pages pour améliorer les performances
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Engineers = lazy(() => import('./pages/Engineers'));
const Sessions = lazy(() => import('./pages/Sessions'));
const SessionDetail = lazy(() => import('./pages/SessionDetail'));
const NewSession = lazy(() => import('./pages/NewSession'));
const Workspace = lazy(() => import('./pages/Workspace'));
const SessionCompleted = lazy(() => import('./pages/SessionCompleted'));
const Reasoning = lazy(() => import('./pages/Reasoning'));
const Stats = lazy(() => import('./pages/Stats'));
const Reports = lazy(() => import('./pages/Reports'));

// Composant de chargement pour Suspense
const PageLoader = () => (
  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh', color: 'var(--gray)' }}>
    <div style={{ textAlign: 'center' }}>
      <div style={{ fontSize: 48, marginBottom: 16 }}>⏳</div>
      <div>Chargement...</div>
    </div>
  </div>
);

const R = ({ el }: { el: React.ReactNode }) => (
  <ProtectedRoute roles={['researcher']}>
    <AppLayout>{el}</AppLayout>
  </ProtectedRoute>
);

const App: React.FC = () => (
  <AuthProvider>
    <ToastProvider>
      <BrowserRouter>
      <Routes>
        <Route path="/" element={<Login />} />
        <Route path="/dashboard" element={
          <Suspense fallback={<PageLoader />}>
            <R el={<Dashboard />} />
          </Suspense>
        } />
        <Route path="/engineers" element={
          <Suspense fallback={<PageLoader />}>
            <R el={<Engineers />} />
          </Suspense>
        } />
        <Route path="/sessions" element={
          <Suspense fallback={<PageLoader />}>
            <R el={<Sessions />} />
          </Suspense>
        } />
        <Route path="/sessions/new" element={
          <Suspense fallback={<PageLoader />}>
            <R el={<NewSession />} />
          </Suspense>
        } />
        <Route path="/sessions/:id" element={
          <Suspense fallback={<PageLoader />}>
            <R el={<SessionDetail />} />
          </Suspense>
        } />
        <Route path="/reasoning" element={
          <Suspense fallback={<PageLoader />}>
            <R el={<Reasoning />} />
          </Suspense>
        } />
        <Route path="/stats" element={
          <Suspense fallback={<PageLoader />}>
            <R el={<Stats />} />
          </Suspense>
        } />
        <Route path="/reports" element={
          <Suspense fallback={<PageLoader />}>
            <R el={<Reports />} />
          </Suspense>
        } />
        <Route path="/workspace/:id" element={
          <Suspense fallback={<PageLoader />}>
            <ProtectedRoute>
              <Workspace />
            </ProtectedRoute>
          </Suspense>
        } />
        <Route path="/session-completed/:id" element={
          <Suspense fallback={<PageLoader />}>
            <ProtectedRoute roles={['engineer']}>
              <SessionCompleted />
            </ProtectedRoute>
          </Suspense>
        } />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
      </BrowserRouter>
    </ToastProvider>
  </AuthProvider>
);

export default App;

