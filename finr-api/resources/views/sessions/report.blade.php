<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Rapport de session</title>
    <style>
        body { font-family: DejaVu Sans, sans-serif; margin: 0; padding: 20px; color: #333; }
        .header { background: #1a1a2e; color: white; padding: 20px; margin: -20px -20px 20px -20px; }
        .title { font-size: 24px; font-weight: bold; margin-bottom: 5px; }
        .subtitle { color: #B0AECF; font-size: 13px; }
        .meta-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 20px; }
        .meta-box { background: #f5f5f5; padding: 10px; border-radius: 6px; }
        .meta-label { font-size: 11px; color: #666; margin-bottom: 4px; }
        .meta-value { font-size: 13px; font-weight: bold; }
        .section { margin-bottom: 20px; }
        .section-title { font-size: 14px; font-weight: bold; margin-bottom: 8px; }
        .problem-box { background: #f0e6ff; padding: 12px; border-radius: 6px; border: 1px solid #AFA9EC; }
        .reasoning-bar { display: flex; align-items: center; gap: 10px; margin-bottom: 6px; }
        .bar-bg { flex: 1; background: #EEECF8; height: 8px; border-radius: 4px; overflow: hidden; }
        .bar-fill { height: 100%; background: #7F77DD; }
        .bar-text { width: 40px; text-align: right; font-weight: 600; }
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 8px 0; border-bottom: 1px solid #ddd; font-size: 12px; color: #666; }
        td { padding: 8px 0; border-bottom: 1px solid #eee; font-size: 13px; }
    </style>
</head>
<body>
    <div class="header">
        <div class="title">FIN-R · Rapport de session</div>
        <div class="subtitle">{{ $session->engineer->user->name ?? '—' }} · {{ $session->created_at->diffForHumans() }}</div>
    </div>

    <div class="meta-grid">
        <div class="meta-box">
            <div class="meta-label">Ingénieur</div>
            <div class="meta-value">{{ $session->engineer->user->name ?? '—' }}</div>
        </div>
        <div class="meta-box">
            <div class="meta-label">Date</div>
            <div class="meta-value">{{ $session->created_at->format('d/m/Y H:i') }}</div>
        </div>
        <div class="meta-box">
            <div class="meta-label">Raisonnement dominant</div>
            <div class="meta-value">{{ $session->dominant_reasoning ?? '—' }}</div>
        </div>
        <div class="meta-box">
            <div class="meta-label">Créativité</div>
            <div class="meta-value">{{ $session->creativity_score ?? '—' }}/10</div>
        </div>
    </div>

    <div class="section">
        <div class="section-title">Problème soumis</div>
        <div class="problem-box">{{ $session->problem }}</div>
    </div>

    @if($session->notes)
    <div class="section">
        <div class="section-title">Notes de l'ingénieur</div>
        <p style="line-height: 1.6; white-space: pre-line;">{{ $session->notes }}</p>
    </div>
    @endif

    @if($reasoning->count() > 0)
    <div class="section">
        <div class="section-title">Profil de raisonnement</div>
        @foreach($reasoning as $r)
        <div class="reasoning-bar">
            <span style="width: 100px; font-size: 12px;">{{ ucfirst($r->type) }}</span>
            <div class="bar-bg">
                <div class="bar-fill" style="width: {{ $r->percentage }}%"></div>
            </div>
            <span class="bar-text">{{ $r->percentage }}%</span>
        </div>
        @endforeach
    </div>
    @endif

    @if($events->count() > 0)
    <div class="section">
        <div class="section-title">Événements captés ({{ $events->count() }})</div>
        <table>
            <thead>
                <tr>
                    <th>Horodatage</th>
                    <th>Type</th>
                    <th>Description</th>
                </tr>
            </thead>
            <tbody>
                @foreach($events as $ev)
                <tr>
                    <td style="font-family: monospace; font-size: 12px;">{{ $ev->timestamp_label }}</td>
                    <td style="font-weight: 600;">{{ ucfirst($ev->type) }}</td>
                    <td>{{ $ev->label }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
    @endif
</body>
</html>