import 'package:shared_preferences/shared_preferences.dart';

class GameProgressService {
  static const String _prefix = 'kiddo_game_progress_';

  /// Returns stars earned on a level (0 if not completed)
  static Future<int> getLevelStars(String gameKey, int levelNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_prefix}${gameKey}_lvl_$levelNumber') ?? 0;
  }

  /// Saves stars earned on a level
  static Future<void> saveLevelStars(
    String gameKey,
    int levelNumber,
    int stars,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBest = prefs.getInt('${_prefix}${gameKey}_lvl_$levelNumber') ?? 0;
    if (stars > currentBest) {
      await prefs.setInt('${_prefix}${gameKey}_lvl_$levelNumber', stars);
    }
  }

  /// Returns total stars earned across all levels in a game
  static Future<int> getTotalStars(String gameKey, int totalLevels) async {
    final prefs = await SharedPreferences.getInstance();
    int total = 0;
    for (int i = 1; i <= totalLevels; i++) {
      total += prefs.getInt('${_prefix}${gameKey}_lvl_$i') ?? 0;
    }
    return total;
  }

  /// Returns highest unlocked level (default is 1)
  static Future<int> getHighestUnlockedLevel(String gameKey) async {
    final prefs = await SharedPreferences.getInstance();
    int unlocked = 1;
    for (int i = 1; i <= 50; i++) {
      final stars = prefs.getInt('${_prefix}${gameKey}_lvl_$i') ?? 0;
      if (stars > 0) {
        unlocked = i + 1;
      } else {
        break;
      }
    }
    return unlocked;
  }
}
