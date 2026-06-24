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

