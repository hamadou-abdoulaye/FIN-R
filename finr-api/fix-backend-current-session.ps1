# FIN-R - Correctif backend : endpoint /me/current-session
# A lancer depuis le dossier finr-api avec PowerShell
$ErrorActionPreference = "Stop"
Write-Host "Application du correctif backend..." -ForegroundColor Cyan

# ---------- app/Http/Controllers/AuthController.php ----------
$file0 = @'
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;

class AuthController extends Controller
{
    /**
     * POST /api/auth/register
     */
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name'     => 'required|string|max:100',
            'email'    => 'required|email|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'role'     => 'required|in:researcher,engineer',
        ]);

        $user = User::create([
            'name'     => $data['name'],
            'email'    => $data['email'],
            'password' => Hash::make($data['password']),
            'role'     => $data['role'],
        ]);

        $token = JWTAuth::fromUser($user);

        return response()->json([
            'user'  => $this->userResource($user),
            'token' => $token,
        ], 201);
    }

    /**
     * POST /api/auth/login
     */
    public function login(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        if (!$token = JWTAuth::attempt($credentials)) {
            return response()->json(['message' => 'Identifiants incorrects.'], 401);
        }

        return response()->json([
            'user'  => $this->userResource(auth()->user()),
            'token' => $token,
        ]);
    }

    /**
     * POST /api/auth/logout
     */
    public function logout(): JsonResponse
    {
        JWTAuth::invalidate(JWTAuth::getToken());
        return response()->json(['message' => 'Déconnecté.']);
    }

    /**
     * POST /api/auth/refresh
     */
    public function refresh(): JsonResponse
    {
        try {
            $token = JWTAuth::refresh(JWTAuth::getToken());
            return response()->json(['token' => $token]);
        } catch (JWTException $e) {
            return response()->json(['message' => 'Token invalide.'], 401);
        }
    }

    /**
     * GET /api/auth/me
     */
    public function me(): JsonResponse
    {
        return response()->json($this->userResource(auth()->user()));
    }

    /**
     * GET /api/me/current-session
     * Retourne la session active la plus récente de l'ingénieur connecté.
     * Utilisé pour rediriger l'ingénieur vers SON espace de travail après login.
     */
    public function currentSession(): JsonResponse
    {
        $user = auth()->user();

        if (!$user->isEngineer() || !$user->engineer) {
            return response()->json(['message' => "Aucun profil ingénieur associé."], 404);
        }

        $session = $user->engineer->sessions()
            ->whereIn('status', ['draft', 'active', 'paused'])
            ->latest()
            ->first();

        if (!$session) {
            return response()->json(['message' => "Aucune session en cours."], 404);
        }

        return response()->json(['id' => $session->id]);
    }

    private function userResource(User $user): array
    {
        return [
            'id'    => $user->id,
            'name'  => $user->name,
            'email' => $user->email,
            'role'  => $user->role,
        ];
    }
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "app\Http\Controllers\AuthController.php"), $file0)
Write-Host "  OK  app/Http/Controllers/AuthController.php"

# ---------- routes/api.php ----------
$file1 = @'
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

    // ── Ingénieur connecté : sa session en cours ───────────────────────────
    Route::get('me/current-session', [SessionController::class, 'myCurrentSession']);

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

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "routes\api.php"), $file1)
Write-Host "  OK  routes/api.php"

Write-Host ""
Write-Host "Correctif backend applique." -ForegroundColor Green
Write-Host "Pensez a relancer: php artisan route:clear" -ForegroundColor Yellow