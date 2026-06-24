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
     * GET /api/sessions/{id}/pdf
     * Génère un rapport PDF de la session.
     */
    public function exportPdf(Session $session)
    {
        $user = auth()->user();

        if ($user->isEngineer()) {
            if (!$user->engineer || $session->engineer_id !== $user->engineer->id) {
                return response()->json(['message' => "Accès refusé : cette session ne vous appartient pas."], 403);
            }
        }

        $session->load(['engineer.user', 'reasoningScores', 'events']);

        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('sessions.report', [
            'session'   => $session,
            'reasoning' => $session->reasoningScores,
            'events'    => $session->events,
        ]);

        return $pdf->download('rapport-session-' . $session->id . '.pdf');
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

