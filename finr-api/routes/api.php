<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\EngineerController;
use App\Http\Controllers\SessionController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| FIN-R API Routes
|--------------------------------------------------------------------------
|
| Auth: JWT via tymon/jwt-auth
| Prefix: /api
|
| Roles:
|   researcher — full access (dashboard, engineers, sessions, stats)
|   engineer   — own sessions only (workspace read/write)
|
*/

// ── Public ────────────────────────────────────────────────────────────────
Route::prefix('auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login',    [AuthController::class, 'login']);
});

// ── Authenticated ──────────────────────────────────────────────────────────
Route::middleware('jwt')->group(function () {
    Route::prefix('auth')->group(function () {
        Route::post('logout',  [AuthController::class, 'logout']);
        Route::post('refresh', [AuthController::class, 'refresh']);
        Route::get('me',       [AuthController::class, 'me']);
    });

    Route::get('me/current-session', [AuthController::class, 'currentSession']);

    // Un ingénieur peut créer son profil après inscription
    Route::post('engineers/profile', [EngineerController::class, 'createProfile']);

    // ── Researcher only : gestion complète ──────────────────────────────────
    Route::middleware('jwt:researcher')->group(function () {
        // Engineers CRUD
        Route::apiResource('engineers', EngineerController::class);

        // Sessions — création, modification, suppression, stats
        Route::get('sessions/stats/global', [SessionController::class, 'globalStats']);
        Route::get('sessions', [SessionController::class, 'index'])->name('sessions.index');
        Route::post('sessions', [SessionController::class, 'store'])->name('sessions.store');
        Route::put('sessions/{session}', [SessionController::class, 'update'])->name('sessions.update');
        Route::patch('sessions/{session}', [SessionController::class, 'update']);
        Route::delete('sessions/{session}', [SessionController::class, 'destroy'])->name('sessions.destroy');
    });

    // ── Engineer or Researcher : consultation d'une session précise ─────────
    // Un ingénieur ne peut voir QUE sa propre session (vérifié dans le contrôleur).
    // Un chercheur peut voir n'importe quelle session.
    Route::get('sessions/{session}', [SessionController::class, 'show'])->name('sessions.show');

    // ── Engineer or Researcher ─────────────────────────────────────────────
    Route::prefix('sessions/{session}')->group(function () {
        Route::post('start',  [SessionController::class, 'start']);
        Route::post('pause',  [SessionController::class, 'pause']);
        Route::post('end',    [SessionController::class, 'end']);
        Route::patch('notes', [SessionController::class, 'updateNotes']);
        Route::get('pdf',     [SessionController::class, 'exportPdf']);
    });
});

