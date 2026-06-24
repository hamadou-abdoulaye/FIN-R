<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;
use Tymon\JWTAuth\Exceptions\JWTException;

class JwtMiddleware
{
    public function handle(Request $request, Closure $next, string ...$roles)
    {
        try {
            $user = JWTAuth::parseToken()->authenticate();
        } catch (TokenExpiredException) {
            return response()->json(['message' => 'Token expiré.'], 401);
        } catch (TokenInvalidException) {
            return response()->json(['message' => 'Token invalide.'], 401);
        } catch (JWTException) {
            return response()->json(['message' => 'Token manquant.'], 401);
        }

        if (!$user) {
            return response()->json(['message' => 'Utilisateur introuvable.'], 401);
        }

        // Role check
        if (!empty($roles) && !in_array($user->role, $roles)) {
            return response()->json(['message' => 'Accès refusé.'], 403);
        }

        return $next($request);
    }
}

