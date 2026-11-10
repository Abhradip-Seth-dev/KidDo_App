import 'package:kiddo_app/core/models/user_model.dart';
import 'package:kiddo_app/core/repositories/user_repository.dart';

/// Local, in-memory implementation of [UserRepository].
/// Used as the active backend until Firebase is configured.
class MockUserRepository implements UserRepository {
  // Mutable user state stored in memory
  UserModel _currentUser = const UserModel(
    id: 'mock_user_id',
    name: 'Satirtha S.',
    avatarUrl: 'assets/images/profile_pic.jpg',
    iq: 1250,
    coins: 450,
    streak: 5,
  );

  final List<UserModel> _leaderboard = [
    const UserModel(id: 'u1', name: 'Aarav M.',   avatarUrl: 'assets/images/kido_character.png', iq: 5400, coins: 0, streak: 0),
    const UserModel(id: 'u2', name: 'Priya K.',   avatarUrl: 'assets/images/kido_character.png', iq: 4800, coins: 0, streak: 0),
    const UserModel(id: 'u3', name: 'Rohan D.',   avatarUrl: 'assets/images/kido_character.png', iq: 4200, coins: 0, streak: 0),
    const UserModel(id: 'u4', name: 'Ananya S.',  avatarUrl: 'assets/images/kido_character.png', iq: 3900, coins: 0, streak: 0),
    const UserModel(id: 'u5', name: 'Vivaan R.',  avatarUrl: 'assets/images/kido_character.png', iq: 3100, coins: 0, streak: 0),
    const UserModel(id: 'u6', name: 'Diya J.',    avatarUrl: 'assets/images/kido_character.png', iq: 2800, coins: 0, streak: 0),
    const UserModel(id: 'u7', name: 'Karan T.',   avatarUrl: 'assets/images/kido_character.png', iq: 2100, coins: 0, streak: 0),
    const UserModel(id: 'mock_user_id', name: 'Satirtha S.', avatarUrl: 'assets/images/profile_pic.jpg', iq: 1250, coins: 450, streak: 5),
    const UserModel(id: 'u8', name: 'Mira V.',    avatarUrl: 'assets/images/kido_character.png', iq: 1100, coins: 0, streak: 0),
    const UserModel(id: 'u9', name: 'Aditya N.',  avatarUrl: 'assets/images/kido_character.png', iq: 950,  coins: 0, streak: 0),
  ];

  @override
  Future<UserModel?> getCurrentUser() async => _currentUser;

  @override
  Stream<UserModel?> watchCurrentUser(String userId) async* {
    yield _currentUser;
  }

  @override
  Future<List<UserModel>> getLeaderboard() async => _leaderboard;

  @override
  Future<void> updateProgress({
    required String userId,
    required int iqDelta,
    required int coinsEarned,
  }) async {
    _currentUser = _currentUser.copyWith(
      iq: _currentUser.iq + iqDelta,
      coins: _currentUser.coins + coinsEarned,
    );
  }

  @override
  Future<void> incrementStreak(String userId) async {
    _currentUser = _currentUser.copyWith(streak: _currentUser.streak + 1);
  }
}
