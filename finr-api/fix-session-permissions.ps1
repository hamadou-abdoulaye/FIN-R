# FIN-R - Correctif : permissions ingenieur sur GET sessions/{id}
Write-Host "Application du correctif permissions..." -ForegroundColor Cyan

# ---------- routes/api.php ----------
$file0 = @'
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
    });
});

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "routes\api.php"), $file0)
Write-Host "  OK  routes/api.php"

# ---------- app/Http/Controllers/SessionController.php ----------
$file1 = @'
<?php

namespace App\Http\Controllers;

use App\Models\Session;
use App\Models\Engineer;
use App\Models\ReasoningScore;
use App\Services\NlpService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use App\Events\SessionUpdated;

class SessionController extends Controller
{
    public function __construct(private NlpService $nlp) {}

    /**
     * GET /api/me/current-session
     * Retourne la session active (ou la plus récente) de l'ingénieur connecté.
     * Utilisé au login pour rediriger vers le bon /workspace/{id}.
     */
    public function myCurrentSession(Request $request): JsonResponse
    {
        $user = $request->user();

        if (!$user || !$user->isEngineer()) {
            return response()->json(['message' => 'Réservé aux ingénieurs.'], 403);
        }

        $engineer = $user->engineer;
        if (!$engineer) {
            return response()->json(['message' => 'Aucun profil ingénieur associé.'], 404);
        }

        // Priorité : session active/en pause, sinon la plus récente (draft inclus)
        $session = Session::where('engineer_id', $engineer->id)
            ->whereIn('status', ['active', 'paused', 'draft'])
            ->latest()
            ->first();

        if (!$session) {
            return response()->json(['message' => 'Aucune session en cours.'], 404);
        }

        $session->load(['engineer.user', 'reasoningScores', 'events']);
        return response()->json($this->resource($session));
    }

    /**
     * GET /api/sessions
     */
    public function index(Request $request): JsonResponse
    {
        $query = Session::with(['engineer.user', 'reasoningScores', 'events'])
            ->latest();

        if ($request->engineer_id) {
            $query->where('engineer_id', $request->engineer_id);
        }
        if ($request->status) {
            $query->where('status', $request->status);
        }

        return response()->json($query->get()->map(fn($s) => $this->resource($s)));
    }

    /**
     * POST /api/sessions
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'engineer_id' => 'required|exists:engineers,id',
            'problem'     => 'required|string|min:10',
        ]);

        $session = Session::create([
            'engineer_id' => $data['engineer_id'],
            'problem'     => $data['problem'],
            'status'      => 'draft',
        ]);

        return response()->json($this->resource($session->load(['engineer.user', 'reasoningScores', 'events'])), 201);
    }

    /**
     * GET /api/sessions/{id}
     * Un chercheur peut voir n'importe quelle session.
     * Un ingénieur ne peut voir QUE ses propres sessions.
     */
    public function show(Session $session): JsonResponse
    {
        $user = auth()->user();

        if ($user->isEngineer()) {
            if (!$user->engineer || $session->engineer_id !== $user->engineer->id) {
                return response()->json(['message' => "Accès refusé : cette session ne vous appartient pas."], 403);
            }
        }

        $session->load(['engineer.user', 'reasoningScores', 'events']);
        return response()->json($this->resource($session));
    }

    /**
     * POST /api/sessions/{id}/start
     */
    public function start(Session $session): JsonResponse
    {
        $this->authorize('update', $session);

        $session->update([
            'status'     => 'active',
            'started_at' => now(),
        ]);

        return response()->json($this->resource($session->fresh()));
    }

    /**
     * POST /api/sessions/{id}/pause
     */
    public function pause(Session $session): JsonResponse
    {
        $session->update(['status' => 'paused']);
        return response()->json($this->resource($session->fresh()));
    }

    /**
     * POST /api/sessions/{id}/end
     */
    public function end(Session $session): JsonResponse
    {
        $session->update([
            'status'   => 'completed',
            'ended_at' => now(),
        ]);

        return response()->json($this->resource($session->fresh(['engineer.user', 'reasoningScores', 'events'])));
    }

    /**
     * PATCH /api/sessions/{id}/notes
     * Called every ~5 seconds from the workspace while engineer types
     */
    public function updateNotes(Request $request, Session $session): JsonResponse
    {
        $data = $request->validate(['notes' => 'required|string']);

        $session->update(['notes' => $data['notes']]);

        // Send to NLP service asynchronously (queued job in production)
        // Here we call synchronously for simplicity
        try {
            $analysis = $this->nlp->analyze($data['notes'], $session->id);
            $this->saveReasoningScores($session, $analysis['scores']);
            $session->update(['creativity_score' => $analysis['creativity_score']]);

            // Broadcast live update to researcher dashboard
            broadcast(new SessionUpdated($session->fresh(['reasoningScores', 'events'])));

            return response()->json([
                'scores'          => $analysis['scores'],
                'creativity_score' => $analysis['creativity_score'],
            ]);
        } catch (\Exception $e) {
            // NLP unavailable — save notes only
            return response()->json(['notes_saved' => true]);
        }
    }

    /**
     * DELETE /api/sessions/{id}
     */
    public function destroy(Session $session): JsonResponse
    {
        $session->delete();
        return response()->json(null, 204);
    }

    // ── Stats ──────────────────────────────────────────────────────────────

    /**
     * GET /api/sessions/stats/global
     */
    public function globalStats(): JsonResponse
    {
        $total = Session::count();
        $completed = Session::completed()->count();
        $avgCreativity = round(Session::completed()->avg('creativity_score') ?? 0, 1);

        $dominantCounts = DB::table('reasoning_scores')
            ->select('type', DB::raw('AVG(percentage) as avg_pct'))
            ->groupBy('type')
            ->orderByDesc('avg_pct')
            ->get();

        return response()->json([
            'total_sessions'    => $total,
            'completed_sessions' => $completed,
            'avg_creativity'    => $avgCreativity,
            'reasoning_distribution' => $dominantCounts,
        ]);
    }

    // ── Private helpers ────────────────────────────────────────────────────

    private function saveReasoningScores(Session $session, array $scores): void
    {
        // Upsert: replace all scores for this session
        ReasoningScore::where('session_id', $session->id)->delete();
        foreach ($scores as $type => $pct) {
            ReasoningScore::create([
                'session_id' => $session->id,
                'type'       => $type,
                'percentage' => $pct,
            ]);
        }
    }

    private function resource(Session $s): array
    {
        return [
            'id'               => $s->id,
            'engineer_id'      => $s->engineer_id,
            'engineer_name'    => $s->engineer?->user?->name,
            'engineer_initials' => $s->engineer?->initials,
            'problem'          => $s->problem,
            'notes'            => $s->notes,
            'status'           => $s->status,
            'date'             => $s->created_at?->diffForHumans(),
            'duration'         => $s->duration,
            'started_at'       => $s->started_at?->toIso8601String(),
            'ended_at'         => $s->ended_at?->toIso8601String(),
            'creativity_score' => $s->creativity_score,
            'dominant_reasoning' => $s->dominant_reasoning,
            'reasoning'        => $s->reasoningScores->map(fn($r) => [
                'type' => $r->type,
                'pct'  => $r->percentage,
            ])->values(),
            'events'           => $s->events->map(fn($e) => [
                'id'        => $e->id,
                'type'      => $e->type,
                'label'     => $e->label,
                'timestamp' => $e->timestamp_label,
                'metadata'  => $e->metadata,
            ])->values(),
        ];
    }
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "app\Http\Controllers\SessionController.php"), $file1)
Write-Host "  OK  app/Http/Controllers/SessionController.php"

Write-Host ""
Write-Host "Correctif applique." -ForegroundColor Green
Write-Host "Lancez maintenant: php artisan route:clear" -ForegroundColor Yellow