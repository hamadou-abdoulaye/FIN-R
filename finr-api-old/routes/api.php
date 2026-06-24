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

    // ── Researcher only ────────────────────────────────────────────────────
    Route::middleware('jwt:researcher')->group(function () {
        // Engineers CRUD
        Route::apiResource('engineers', EngineerController::class);

        // Sessions
        Route::get('sessions/stats/global', [SessionController::class, 'globalStats']);
        Route::apiResource('sessions', SessionController::class);
    });

    // ── Engineer or Researcher ─────────────────────────────────────────────
    Route::prefix('sessions/{session}')->group(function () {
        Route::post('start',  [SessionController::class, 'start']);
        Route::post('pause',  [SessionController::class, 'pause']);
        Route::post('end',    [SessionController::class, 'end']);
        Route::patch('notes', [SessionController::class, 'updateNotes']);
    });
});
