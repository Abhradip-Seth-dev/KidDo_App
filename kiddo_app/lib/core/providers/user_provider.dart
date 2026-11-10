import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiddo_app/core/models/user_model.dart';
import 'package:kiddo_app/core/providers/auth_provider.dart';
import 'package:kiddo_app/core/repositories/user_repository.dart';
import 'package:kiddo_app/core/repositories/api_user_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repository provider — using ApiUserRepository (Node.js + MongoDB backend).
// ─────────────────────────────────────────────────────────────────────────────
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return ApiUserRepository(); // ← Live Node.js API
});

// ── Current user profile provider ────────────────────────────────────────────
// Automatically reacts when auth status or logged-in user changes
final userProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.status != AuthStatus.authenticated || authState.userId == null) {
    return null;
  }
  final repo = ref.watch(userRepositoryProvider);
  return repo.getCurrentUser();
});

// ── Leaderboard provider ──────────────────────────────────────────────────────
final leaderboardProvider = FutureProvider<List<UserModel>>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getLeaderboard();
});
