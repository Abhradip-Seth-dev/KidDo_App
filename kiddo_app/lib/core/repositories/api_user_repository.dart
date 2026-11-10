import 'package:dio/dio.dart';
import 'package:kiddo_app/core/models/user_model.dart';
import 'package:kiddo_app/core/repositories/user_repository.dart';
import 'package:kiddo_app/core/services/api_service.dart';

/// Real implementation of [UserRepository] backed by the Node.js + MongoDB API.
///
/// Swap this in via [userRepositoryProvider] in user_provider.dart.
class ApiUserRepository implements UserRepository {
  final ApiService _api = ApiService();

  // ── Helpers ──────────────────────────────────────────────────────────────────
  UserModel _fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email']?.toString() ?? '',
      avatarUrl: (json['avatarUrl'] as String?) ??
          'assets/images/kido_character.png',
      iq: (json['iq'] as num?)?.toInt() ?? 0,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      age: (json['age'] as num?)?.toInt() ?? 8,
      gradeClass: json['gradeClass']?.toString() ?? 'Class 3',
      hasCompletedOnboarding: (json['hasCompletedOnboarding'] as bool?) ?? false,
    );
  }

  // ── UserRepository impl ───────────────────────────────────────────────────────
  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _api.get('/users/profile');
      final data = response.data as Map<String, dynamic>;
      return _fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to fetch user: ${e.error}');
    }
  }

  @override
  Stream<UserModel?> watchCurrentUser(String userId) async* {
    // REST API doesn't support real-time streams.
    // Poll every 30 seconds as a simple alternative.
    while (true) {
      try {
        yield await getCurrentUser();
      } catch (_) {
        yield null;
      }
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  @override
  Future<List<UserModel>> getLeaderboard() async {
    try {
      final response = await _api.get('/users/leaderboard');
      final data = response.data as Map<String, dynamic>;
      final users = data['users'] as List<dynamic>;
      return users
          .map((u) => _fromJson(u as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch leaderboard: ${e.error}');
    }
  }

  @override
  Future<void> updateProgress({
    required String userId,
    required int iqDelta,
    required int coinsEarned,
  }) async {
    // Progress is updated via the quiz submit endpoint.
    // This method is kept as no-op here because the quiz controller
    // on the backend handles the atomic update directly.
    // If called from shop (coin deduction), it goes through shop/purchase.
  }

  @override
  Future<void> incrementStreak(String userId) async {
    // Streak is updated automatically on login in auth.controller.js
  }
}
