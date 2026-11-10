import 'package:kiddo_app/core/models/game_models.dart';
import 'package:kiddo_app/core/services/api_service.dart';
import 'package:kiddo_app/features/games/game_progress_service.dart';

class GameService {
  final ApiService _api = ApiService();

  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  /// Fetches master list of active games with user progress
  Future<List<GameMetadata>> getGames() async {
    try {
      final res = await _api.get('/games');
      final data = res.data;
      if (data['success'] == true && data['games'] is List) {
        return (data['games'] as List)
            .map((g) => GameMetadata.fromJson(g as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Fetches levels list for a specific game
  Future<List<GameLevelItem>> getGameLevels(String gameKey) async {
    try {
      final res = await _api.get('/games/$gameKey/levels');
      final data = res.data;
      if (data['success'] == true && data['levels'] is List) {
        return (data['levels'] as List)
            .map((l) => GameLevelItem.fromJson(l as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Fetches full Math Puzzle level data including questions
  Future<MathPuzzleLevelData?> getMathPuzzleLevel(int levelNumber) async {
    try {
      final res = await _api.get('/games/math_puzzle/levels/$levelNumber');
      final data = res.data;
      if (data['success'] == true && data['level'] is Map) {
        return MathPuzzleLevelData.fromJson(
          data['level'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetches full Word Scramble level data including word list
  Future<WordScrambleLevelData?> getWordScrambleLevel(int levelNumber) async {
    try {
      final res = await _api.get('/games/word_scramble/levels/$levelNumber');
      final data = res.data;
      if (data['success'] == true && data['level'] is Map) {
        return WordScrambleLevelData.fromJson(
          data['level'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetches full Memory Match level data including grid & timing configs
  Future<MemoryMatchLevelData?> getMemoryMatchLevel(int levelNumber) async {
    try {
      final res = await _api.get('/games/memory_match/levels/$levelNumber');
      final data = res.data;
      if (data['success'] == true && data['level'] is Map) {
        return MemoryMatchLevelData.fromJson(
          data['level'] as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Submits game completion score and receives rewards (+IQ, +Coins)
  Future<GameSubmitResponse?> submitGameLevel({
    required String gameKey,
    required int levelNumber,
    required int stars,
    int score = 0,
    int? moves,
    int? timeSeconds,
  }) async {
    // Also save in local storage for offline fast load
    await GameProgressService.saveLevelStars(gameKey, levelNumber, stars);

    try {
      final res = await _api.post(
        '/games/submit',
        data: {
          'gameKey': gameKey,
          'levelNumber': levelNumber,
          'stars': stars,
          'score': score,
          if (moves != null) 'moves': moves,
          if (timeSeconds != null) 'timeSeconds': timeSeconds,
        },
      );

      final data = res.data;
      if (data['success'] == true) {
        return GameSubmitResponse.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      // Return local fallback response if network fails
      return GameSubmitResponse(
        success: true,
        gameKey: gameKey,
        levelNumber: levelNumber,
        stars: stars,
        iqEarned: stars * 10,
        coinsEarned: stars * 5,
        nextLevelUnlocked: levelNumber + 1,
      );
    }
  }
}
