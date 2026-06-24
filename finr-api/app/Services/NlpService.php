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

