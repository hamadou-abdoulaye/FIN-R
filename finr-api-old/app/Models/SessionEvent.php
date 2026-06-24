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
