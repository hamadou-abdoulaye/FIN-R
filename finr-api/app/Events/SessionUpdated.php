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
            'session_id'       => $this->session->id,
            'notes'            => $this->session->notes,
            'reasoning'        => $this->session->reasoningScores->map(fn($r) => [
                'type' => $r->type,
                'pct'  => $r->percentage,
            ])->values(),
            'creativity_score' => $this->session->creativity_score,
            'events'           => $this->session->events->map(fn($e) => [
                'id'        => $e->id,
                'type'      => $e->type,
                'label'     => $e->label,
                'timestamp' => $e->timestamp_label,
            ])->values()->last(3), // last 3 events only
        ];
    }
}

