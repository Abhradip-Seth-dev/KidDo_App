import 'package:kiddo_app/core/models/user_model.dart';

/// Abstract contract for all user data operations.
/// Implement with MockUserRepository (local) or FirebaseUserRepository (live).
abstract class UserRepository {
  /// Returns the currently authenticated user's profile, or null if not signed in.
  Future<UserModel?> getCurrentUser();

  /// Returns a stream of the user's profile — updates in real-time (e.g. Firestore listener).
  Stream<UserModel?> watchCurrentUser(String userId);

  /// Returns the global leaderboard, sorted by IQ descending.
  Future<List<UserModel>> getLeaderboard();

  /// Increments the user's IQ by [delta] and their coins by [coinsEarned].
  Future<void> updateProgress({
    required String userId,
    required int iqDelta,
    required int coinsEarned,
  });

  /// Increments the user's daily streak by 1.
  Future<void> incrementStreak(String userId);
}
