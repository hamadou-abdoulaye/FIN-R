<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Session extends Model
{
    use HasFactory;

    protected $table = 'research_sessions';

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

