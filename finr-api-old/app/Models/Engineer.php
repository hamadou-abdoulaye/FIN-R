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
