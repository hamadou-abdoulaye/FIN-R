# FIN-R - Installation des fichiers backend (v3)
# A lancer depuis le dossier finr-api avec PowerShell
$ErrorActionPreference = "Stop"
Write-Host "Installation des fichiers FIN-R..." -ForegroundColor Cyan

# ---------- app/Models/User.php ----------
$file0 = @'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class User extends Authenticatable implements JWTSubject
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role', // 'researcher' | 'engineer'
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    // JWT interface
    public function getJWTIdentifier(): mixed
    {
        return $this->getKey();
    }

    public function getJWTCustomClaims(): array
    {
        return [
            'role' => $this->role,
            'name' => $this->name,
        ];
    }

    // Relations
    public function engineer()
    {
        return $this->hasOne(Engineer::class);
    }

    public function isResearcher(): bool
    {
        return $this->role === 'researcher';
    }

    public function isEngineer(): bool
    {
        return $this->role === 'engineer';
    }
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "app\Models\User.php"), $file0)
Write-Host "  OK  app/Models/User.php"

# ---------- app/Models/Engineer.php ----------
$file1 = @'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Engineer extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'specialty',
        'initials',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function sessions()
    {
        return $this->hasMany(Session::class);
    }

    // Computed: dominant reasoning type across all sessions
    public function getDominantReasoningAttribute(): ?string
    {
        $sessions = $this->sessions()->with('reasoningScores')->get();
        if ($sessions->isEmpty()) return null;

        $totals = [];
        foreach ($sessions as $session) {
            foreach ($session->reasoningScores as $score) {
                $totals[$score->type] = ($totals[$score->type] ?? 0) + $score->percentage;
            }
        }
        if (empty($totals)) return null;

        arsort($totals);
        return array_key_first($totals);
    }

    public function getAverageCreativityScoreAttribute(): float
    {
        return round($this->sessions()->avg('creativity_score') ?? 0, 1);
    }
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "app\Models\Engineer.php"), $file1)
Write-Host "  OK  app/Models/Engineer.php"

# ---------- app/Models/Session.php ----------
$file2 = @'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Session extends Model
{
    use HasFactory;

    protected $fillable = [
        'engineer_id',
        'problem',
        'notes',
        'status',        // draft | active | paused | completed
        'started_at',
        'ended_at',
        'creativity_score',
    ];

    protected function casts(): array
    {
        return [
            'started_at'       => 'datetime',
            'ended_at'         => 'datetime',
            'creativity_score' => 'float',
        ];
    }

    // Relations
    public function engineer()
    {
        return $this->belongsTo(Engineer::class);
    }

    public function events()
    {
        return $this->hasMany(SessionEvent::class)->orderBy('occurred_at');
    }

    public function reasoningScores()
    {
        return $this->hasMany(ReasoningScore::class);
    }

    // Helpers
    public function getDurationAttribute(): ?string
    {
        if (!$this->started_at || !$this->ended_at) return null;
        $diff = $this->started_at->diff($this->ended_at);
        if ($diff->h > 0) {
            return $diff->h . 'h' . ($diff->i > 0 ? sprintf('%02d', $diff->i) : '');
        }
        return $diff->i . ' min';
    }

    public function getDominantReasoningAttribute(): ?string
    {
        $top = $this->reasoningScores()->orderByDesc('percentage')->first();
        return $top?->type;
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "app\Models\Session.php"), $file2)
Write-Host "  OK  app/Models/Session.php"

# ---------- app/Models/SessionEvent.php ----------
$file3 = @'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SessionEvent extends Model
{
    protected $fillable = [
        'session_id',
        'type',          // decomposition | analogy | hesitation | insight | backtrack
        'label',
        'occurred_at',
        'metadata',      // JSON: extra context
    ];

    protected function casts(): array
    {
        return [
            'occurred_at' => 'datetime',
            'metadata'    => 'array',
        ];
    }

    public function session()
    {
        return $this->belongsTo(Session::class);
    }

    public function getTimestampLabelAttribute(): string
    {
        if (!$this->session?->started_at) return '00:00:00';
        $diff = $this->session->started_at->diff($this->occurred_at);
        return sprintf('%02d:%02d:%02d', $diff->h, $diff->i, $diff->s);
    }
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "app\Models\SessionEvent.php"), $file3)
Write-Host "  OK  app/Models/SessionEvent.php"

# ---------- app/Models/ReasoningScore.php ----------
$file4 = @'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ReasoningScore extends Model
{
    protected $fillable = [
        'session_id',
        'type',        // Analytique | Créatif | Par analogie | Essai-erreur | Systémique
        'percentage',
    ];

    protected function casts(): array
    {
        return ['percentage' => 'float'];
    }

    public function session()
    {
        return $this->belongsTo(Session::class);
    }
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "app\Models\ReasoningScore.php"), $file4)
Write-Host "  OK  app/Models/ReasoningScore.php"

# ---------- app/Http/Controllers/AuthController.php ----------
$file5 = @'
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
[System.IO.File]::WriteAllText((Join-Path $PWD "app\Http\Controllers\AuthController.php"), $file5)
Write-Host "  OK  app/Http/Controllers/AuthController.php"

# ---------- app/Http/Controllers/EngineerController.php ----------
$file6 = @'
<?php

namespace App\Http\Controllers;

use App\Models\Engineer;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class EngineerController extends Controller
{
    /**
     * GET /api/engineers
     */
    public function index(): JsonResponse
    {
        $engineers = Engineer::with(['user', 'sessions.reasoningScores'])
            ->latest()
            ->get()
            ->map(fn($e) => $this->resource($e));

        return response()->json($engineers);
    }

    /**
     * POST /api/engineers
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name'      => 'required|string|max:100',
            'email'     => 'required|email|unique:users',
            'specialty' => 'required|string|max:100',
        ]);

        // Create linked user account
        $user = User::create([
            'name'     => $data['name'],
            'email'    => $data['email'],
            'password' => Hash::make(Str::random(16)), // reset via email in production
            'role'     => 'engineer',
        ]);

        $initials = collect(explode(' ', $data['name']))
            ->map(fn($w) => strtoupper(substr($w, 0, 1)))
            ->take(2)
            ->join('');

        $engineer = Engineer::create([
            'user_id'   => $user->id,
            'specialty' => $data['specialty'],
            'initials'  => $initials,
        ]);

        return response()->json($this->resource($engineer->load('user')), 201);
    }

    /**
     * GET /api/engineers/{id}
     */
    public function show(Engineer $engineer): JsonResponse
    {
        $engineer->load(['user', 'sessions.reasoningScores', 'sessions.events']);
        return response()->json($this->resource($engineer));
    }

    /**
     * PUT /api/engineers/{id}
     */
    public function update(Request $request, Engineer $engineer): JsonResponse
    {
        $data = $request->validate([
            'specialty' => 'sometimes|string|max:100',
            'name'      => 'sometimes|string|max:100',
        ]);

        if (isset($data['specialty'])) {
            $engineer->update(['specialty' => $data['specialty']]);
        }
        if (isset($data['name'])) {
            $engineer->user->update(['name' => $data['name']]);
        }

        return response()->json($this->resource($engineer->fresh(['user'])));
    }

    /**
     * DELETE /api/engineers/{id}
     */
    public function destroy(Engineer $engineer): JsonResponse
    {
        $engineer->user->delete(); // cascades to engineer + sessions
        return response()->json(null, 204);
    }

    private function resource(Engineer $e): array
    {
        $sessions = $e->sessions ?? collect();
        return [
            'id'               => $e->id,
            'name'             => $e->user->name,
            'email'            => $e->user->email,
            'initials'         => $e->initials,
            'specialty'        => $e->specialty,
            'sessions_count'   => $sessions->count(),
            'last_session'     => $sessions->sortByDesc('created_at')->first()?->created_at?->diffForHumans(),
            'dominant_reasoning' => $e->dominant_reasoning,
            'avg_creativity'   => $e->average_creativity_score,
        ];
    }
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "app\Http\Controllers\EngineerController.php"), $file6)
Write-Host "  OK  app/Http/Controllers/EngineerController.php"

# ---------- app/Http/Controllers/SessionController.php ----------
$file7 = @'
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
     */
    public function show(Session $session): JsonResponse
    {
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
[System.IO.File]::WriteAllText((Join-Path $PWD "app\Http\Controllers\SessionController.php"), $file7)
Write-Host "  OK  app/Http/Controllers/SessionController.php"

# ---------- app/Http/Middleware/JwtMiddleware.php ----------
$file8 = @'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;
use Tymon\JWTAuth\Exceptions\JWTException;

class JwtMiddleware
{
    public function handle(Request $request, Closure $next, string ...$roles)
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();
        } catch (TokenExpiredException) {
            return response()->json(['message' => 'Token expiré.'], 401);
        } catch (TokenInvalidException) {
            return response()->json(['message' => 'Token invalide.'], 401);
        } catch (JWTException) {
            return response()->json(['message' => 'Token manquant.'], 401);
        }

        if (!$user) {
            return response()->json(['message' => 'Utilisateur introuvable.'], 401);
        }

        // Role check
        if (!empty($roles) && !in_array($user->role, $roles)) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        return $next($request);
    }
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "app\Http\Middleware\JwtMiddleware.php"), $file8)
Write-Host "  OK  app/Http/Middleware/JwtMiddleware.php"

# ---------- app/Services/NlpService.php ----------
$file9 = @'
<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class NlpService
{
    private string $baseUrl;

    public function __construct()
    {
        $this->baseUrl = config('services.nlp.url', env('NLP_SERVICE_URL', 'http://localhost:8001'));
    }

    /**
     * Send text to the Python NLP microservice and get reasoning analysis back.
     *
     * Returns:
     * [
     *   'scores' => [
     *     'Analytique'   => 72.0,
     *     'Par analogie' => 20.0,
     *     'Créatif'      => 8.0,
     *     ...
     *   ],
     *   'creativity_score' => 6.4,
     *   'events' => [
     *     ['type' => 'decomposition', 'label' => '...', 'confidence' => 0.88],
     *     ...
     *   ]
     * ]
     */
    public function analyze(string $text, int $sessionId): array
    {
        $response = Http::timeout(10)
            ->post("{$this->baseUrl}/analyze", [
                'text'       => $text,
                'session_id' => $sessionId,
            ]);

        if ($response->failed()) {
            Log::warning("NLP service error for session {$sessionId}: " . $response->status());
            throw new \RuntimeException('NLP service unavailable');
        }

        return $response->json();
    }

    /**
     * Detect micro-events from a keystroke delta (called more frequently).
     */
    public function detectEvents(string $delta, string $context, int $sessionId): array
    {
        try {
            $response = Http::timeout(5)
                ->post("{$this->baseUrl}/events", [
                    'delta'      => $delta,
                    'context'    => $context,
                    'session_id' => $sessionId,
                ]);

            return $response->successful() ? ($response->json()['events'] ?? []) : [];
        } catch (\Exception $e) {
            Log::debug("NLP event detection failed: " . $e->getMessage());
            return [];
        }
    }

    /**
     * Health check.
     */
    public function isAvailable(): bool
    {
        try {
            return Http::timeout(2)->get("{$this->baseUrl}/health")->successful();
        } catch (\Exception) {
            return false;
        }
    }
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "app\Services\NlpService.php"), $file9)
Write-Host "  OK  app/Services/NlpService.php"

# ---------- app/Events/SessionUpdated.php ----------
$file10 = @'
<?php

namespace App\Events;

use App\Models\Session;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class SessionUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(public Session $session) {}

    /**
     * Broadcast on channel: session.{id}
     * The researcher subscribes to this channel to get live updates.
     */
    public function broadcastOn(): array
    {
        return [
            new Channel("session.{$this->session->id}"),
        ];
    }

    public function broadcastAs(): string
    {
        return 'session.updated';
    }

    public function broadcastWith(): array
    {
        return [
            'session_id'      => $this->session->id,
            'reasoning'       => $this->session->reasoningScores->map(fn($r) => [
                'type' => $r->type,
                'pct'  => $r->percentage,
            ])->values(),
            'creativity_score' => $this->session->creativity_score,
            'events'          => $this->session->events->map(fn($e) => [
                'id'        => $e->id,
                'type'      => $e->type,
                'label'     => $e->label,
                'timestamp' => $e->timestamp_label,
            ])->values()->last(3), // last 3 events only
        ];
    }
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "app\Events\SessionUpdated.php"), $file10)
Write-Host "  OK  app/Events/SessionUpdated.php"

# ---------- bootstrap/app.php ----------
$file11 = @'
<?php

use App\Http\Middleware\JwtMiddleware;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        api: __DIR__.'/../routes/api.php',
        apiPrefix: 'api',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // CORS for React frontend
        $middleware->api(prepend: [
            \Illuminate\Http\Middleware\HandleCors::class,
        ]);

        // Register named middleware aliases
        $middleware->alias([
            'jwt' => JwtMiddleware::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // Return JSON errors for API
        $exceptions->render(function (\Illuminate\Validation\ValidationException $e, $request) {
            if ($request->expectsJson()) {
                return response()->json([
                    'message' => 'Erreur de validation.',
                    'errors'  => $e->errors(),
                ], 422);
            }
        });

        $exceptions->render(function (\Illuminate\Database\Eloquent\ModelNotFoundException $e, $request) {
            if ($request->expectsJson()) {
                return response()->json(['message' => 'Ressource introuvable.'], 404);
            }
        });
    })->create();

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "bootstrap\app.php"), $file11)
Write-Host "  OK  bootstrap/app.php"

# ---------- config/cors.php ----------
$file12 = @'
<?php

return [
    'paths'                    => ['api/*'],
    'allowed_methods'          => ['*'],
    'allowed_origins'          => [env('FRONTEND_URL', 'http://localhost:3000')],
    'allowed_origins_patterns' => [],
    'allowed_headers'          => ['*'],
    'exposed_headers'          => [],
    'max_age'                  => 0,
    'supports_credentials'     => true,
];

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "config\cors.php"), $file12)
Write-Host "  OK  config/cors.php"

# ---------- database/migrations/2024_01_01_000001_create_finr_tables.php ----------
$file13 = @'
<?php
// database/migrations/2024_01_01_000001_create_finr_tables.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Users (auth)
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('password');
            $table->enum('role', ['researcher', 'engineer'])->default('engineer');
            $table->timestamp('email_verified_at')->nullable();
            $table->rememberToken();
            $table->timestamps();
        });

        // Engineers (linked 1-1 to users)
        Schema::create('engineers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('specialty');
            $table->string('initials', 3);
            $table->timestamps();
        });

        // Sessions
        Schema::create('sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('engineer_id')->constrained()->cascadeOnDelete();
            $table->text('problem');
            $table->text('notes')->nullable();
            $table->enum('status', ['draft', 'active', 'paused', 'completed'])->default('draft');
            $table->timestamp('started_at')->nullable();
            $table->timestamp('ended_at')->nullable();
            $table->decimal('creativity_score', 4, 1)->nullable();
            $table->timestamps();
        });

        // Reasoning scores per session (one row per reasoning type)
        Schema::create('reasoning_scores', function (Blueprint $table) {
            $table->id();
            $table->foreignId('session_id')->constrained()->cascadeOnDelete();
            $table->string('type'); // Analytique | Créatif | Par analogie | Essai-erreur | Systémique
            $table->decimal('percentage', 5, 2);
            $table->timestamps();

            $table->unique(['session_id', 'type']);
        });

        // Session events (timeline)
        Schema::create('session_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('session_id')->constrained()->cascadeOnDelete();
            $table->enum('type', ['decomposition', 'analogy', 'hesitation', 'insight', 'backtrack']);
            $table->string('label');
            $table->timestamp('occurred_at');
            $table->json('metadata')->nullable();
            $table->timestamps();

            $table->index(['session_id', 'occurred_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('session_events');
        Schema::dropIfExists('reasoning_scores');
        Schema::dropIfExists('sessions');
        Schema::dropIfExists('engineers');
        Schema::dropIfExists('users');
    }
};

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "database\migrations\2024_01_01_000001_create_finr_tables.php"), $file13)
Write-Host "  OK  database/migrations/2024_01_01_000001_create_finr_tables.php"

# ---------- database/seeders/DatabaseSeeder.php ----------
$file14 = @'
<?php

namespace Database\Seeders;

use App\Models\Engineer;
use App\Models\ReasoningScore;
use App\Models\Session;
use App\Models\SessionEvent;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Researcher account
        User::create([
            'name'     => 'Dr. Amadou Koné',
            'email'    => 'a.kone@esp.sn',
            'password' => Hash::make('password'),
            'role'     => 'researcher',
        ]);

        // Engineers + their sessions
        $engineersData = [
            [
                'name' => 'Awa Mbaye', 'email' => 'a.mbaye@esp.sn',
                'specialty' => 'Génie mécanique', 'initials' => 'AM',
                'problem' => 'Concevoir un système de fixation léger pour panneaux solaires sur tôle ondulée tropicale. Résistance > 120 km/h, coût < 15 000 FCFA/unité.',
                'notes' => "Le système doit résister à des vents violents.\n\n1. Charge au vent — pression ≈ 240 Pa à 120 km/h.\n2. Matériaux — inox ou aluminium anodisé.\n3. Coût — éléments standards du marché local.",
                'creativity' => 6.4,
                'reasoning' => [['Analytique', 72], ['Par analogie', 20], ['Créatif', 8]],
                'events' => [
                    ['decomposition', 'Décomposition en 3 contraintes', 130],
                    ['analogy', 'Référence à système européen', 875],
                    ['hesitation', 'Hésitation · retour matériau (18 s)', 1248],
                    ['insight', 'Solution hybride identifiée', 2302],
                ],
            ],
            [
                'name' => 'Omar Diallo', 'email' => 'o.diallo@esp.sn',
                'specialty' => 'Génie électrique', 'initials' => 'OD',
                'problem' => "Optimiser le rendement d'un système d'éclairage LED autonome pour habitat rural sans accès au réseau électrique.",
                'notes' => "Explorer des solutions low-cost adaptées au marché local.\nPriorité à la durabilité et à la maintenabilité.",
                'creativity' => 8.1,
                'reasoning' => [['Créatif', 55], ['Analytique', 30], ['Systémique', 15]],
                'events' => [
                    ['insight', 'Idée capteur de luminosité ambiante', 320],
                    ['analogy', 'Analogie avec firefly bioluminescence', 1320],
                    ['backtrack', 'Abandon batterie NiMH → Li-ion', 2710],
                ],
            ],
            [
                'name' => 'Fatou Sow', 'email' => 'f.sow@esp.sn',
                'specialty' => 'Génie informatique', 'initials' => 'FS',
                'problem' => 'Concevoir un algorithme de routage pour un réseau de capteurs IoT en milieu agricole au Sénégal.',
                'notes' => "Contrainte principale : autonomie des nœuds capteurs.\nProtocole doit minimiser les transmissions.",
                'creativity' => 7.2,
                'reasoning' => [['Par analogie', 48], ['Analytique', 35], ['Créatif', 17]],
                'events' => [
                    ['analogy', 'Analogie réseau de fourmis', 495],
                    ['decomposition', 'Décomposition topologie réseau', 1120],
                    ['insight', 'Protocole hybride AODV+énergie', 1860],
                ],
            ],
            [
                'name' => 'Moussa Bâ', 'email' => 'm.ba@esp.sn',
                'specialty' => 'Génie civil', 'initials' => 'MB',
                'problem' => 'Calculer la résistance d\'un pont piétonnier en bois traité pour une portée de 12 m en zone humide.',
                'notes' => "Dimensionnement poutres maîtresses.\nCharges climatiques : humidité permanente, dilatation thermique.",
                'creativity' => 5.8,
                'reasoning' => [['Essai-erreur', 60], ['Analytique', 32], ['Systémique', 8]],
                'events' => [
                    ['decomposition', 'Décomposition charges statiques/dynamiques', 240],
                    ['hesitation', '3 tentatives section poutre', 1230],
                    ['backtrack', 'Changement essence de bois', 2335],
                ],
            ],
        ];

        foreach ($engineersData as $data) {
            $user = User::create([
                'name'     => $data['name'],
                'email'    => $data['email'],
                'password' => Hash::make('password'),
                'role'     => 'engineer',
            ]);

            $engineer = Engineer::create([
                'user_id'   => $user->id,
                'specialty' => $data['specialty'],
                'initials'  => $data['initials'],
            ]);

            $startedAt = now()->subHours(rand(1, 120));
            $duration  = rand(30, 90) * 60;
            $endedAt   = $startedAt->copy()->addSeconds($duration);

            $session = Session::create([
                'engineer_id'      => $engineer->id,
                'problem'          => $data['problem'],
                'notes'            => $data['notes'],
                'status'           => 'completed',
                'started_at'       => $startedAt,
                'ended_at'         => $endedAt,
                'creativity_score' => $data['creativity'],
            ]);

            foreach ($data['reasoning'] as [$type, $pct]) {
                ReasoningScore::create([
                    'session_id' => $session->id,
                    'type'       => $type,
                    'percentage' => $pct,
                ]);
            }

            foreach ($data['events'] as [$type, $label, $secondsOffset]) {
                SessionEvent::create([
                    'session_id'  => $session->id,
                    'type'        => $type,
                    'label'       => $label,
                    'occurred_at' => $startedAt->copy()->addSeconds($secondsOffset),
                ]);
            }
        }
    }
}

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "database\seeders\DatabaseSeeder.php"), $file14)
Write-Host "  OK  database/seeders/DatabaseSeeder.php"

# ---------- routes/api.php ----------
$file15 = @'
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

'@
[System.IO.File]::WriteAllText((Join-Path $PWD "routes\api.php"), $file15)
Write-Host "  OK  routes/api.php"

Write-Host ""
Write-Host "Installation terminee : 16 fichiers crees." -ForegroundColor Green
Write-Host ""
Write-Host "Verification (fichiers suspects < 50 octets) :" -ForegroundColor Cyan
$bad = Get-ChildItem -Recurse -Include *.php | Where-Object { $_.Length -lt 50 -and $_.Name -ne "Controller.php" }
if ($bad) { $bad | ForEach-Object { Write-Host "  PROBLEME: $($_.FullName) ($($_.Length) octets)" -ForegroundColor Red } } else { Write-Host "  Tout est OK." -ForegroundColor Green }