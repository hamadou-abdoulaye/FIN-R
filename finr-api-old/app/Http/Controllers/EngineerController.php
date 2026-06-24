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
