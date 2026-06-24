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

