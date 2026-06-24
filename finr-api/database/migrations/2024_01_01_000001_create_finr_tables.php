<?php
// database/migrations/2024_01_01_000001_create_finr_tables.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Engineers (linked 1-1 to users)
        Schema::create('engineers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('specialty');
            $table->string('initials', 3);
            $table->timestamps();
        });

        // Research sessions (renommé pour éviter le conflit avec la table
        // "sessions" par défaut de Laravel, utilisée pour les cookies HTTP)
        Schema::create('research_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('engineer_id')->constrained('engineers')->cascadeOnDelete();
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
            $table->foreignId('session_id')->constrained('research_sessions')->cascadeOnDelete();
            $table->string('type'); // Analytique | Créatif | Par analogie | Essai-erreur | Systémique
            $table->decimal('percentage', 5, 2);
            $table->timestamps();

            $table->unique(['session_id', 'type']);
        });

        // Session events (timeline)
        Schema::create('session_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('session_id')->constrained('research_sessions')->cascadeOnDelete();
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
        Schema::dropIfExists('research_sessions');
        Schema::dropIfExists('engineers');
    }
};

