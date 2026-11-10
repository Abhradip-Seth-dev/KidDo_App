import 'package:flutter/material.dart';

/// Game master card info
class GameMetadata {
  final String id;
  final String gameKey;
  final String title;
  final String description;
  final String emoji;
  final String category;
  final Color color;
  final List<Color> gradientColors;
  final int totalLevels;
  final int earnedStars;
  final int unlockedLevels;

  const GameMetadata({
    required this.id,
    required this.gameKey,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.color,
    required this.gradientColors,
    required this.totalLevels,
    this.earnedStars = 0,
    this.unlockedLevels = 1,
  });

  factory GameMetadata.fromJson(Map<String, dynamic> json) {
    Color parseHexColor(String? hex, Color fallback) {
      if (hex == null || hex.isEmpty) return fallback;
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('0xFF$clean'));
      }
      return fallback;
    }

    final rawGradients = json['gradientColors'] as List<dynamic>? ?? [];
    final List<Color> gradients = rawGradients.map((g) {
      return parseHexColor(g?.toString(), const Color(0xFF6C63FF));
    }).toList();

    return GameMetadata(
      id: json['_id']?.toString() ?? '',
      gameKey: json['gameKey']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🎮',
      category: json['category']?.toString() ?? '10 Levels',
      color: parseHexColor(json['color']?.toString(), const Color(0xFF38BDF8)),
      gradientColors: gradients.isNotEmpty
          ? gradients
          : const [Color(0xFF6C63FF), Color(0xFF9B59B6)],
      totalLevels: json['totalLevels'] as int? ?? 10,
      earnedStars: json['earnedStars'] as int? ?? 0,
      unlockedLevels: json['unlockedLevels'] as int? ?? 1,
    );
  }
}

/// Level node info in the level selection screen
class GameLevelItem {
  final int levelNumber;
  final String title;
  final String description;
  final String icon;
  final int stars;
  final int bestScore;
  final bool isCompleted;
  final bool isUnlocked;

  const GameLevelItem({
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.icon,
    this.stars = 0,
    this.bestScore = 0,
    this.isCompleted = false,
    this.isUnlocked = false,
  });

  factory GameLevelItem.fromJson(Map<String, dynamic> json) {
    return GameLevelItem(
      levelNumber: json['levelNumber'] as int? ?? 1,
      title: json['title']?.toString() ?? 'Level',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '⭐',
      stars: json['stars'] as int? ?? 0,
      bestScore: json['bestScore'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isUnlocked: json['isUnlocked'] as bool? ?? (json['levelNumber'] == 1),
    );
  }
}

// ── Math Puzzle Models ─────────────────────────────────────────────────────────

enum MathPuzzleType {
  symbolAlgebra,
  numberPattern,
  mathRiddle,
  logicGrid;

  static MathPuzzleType fromString(String type) {
    switch (type) {
      case 'symbolAlgebra':
        return MathPuzzleType.symbolAlgebra;
      case 'numberPattern':
        return MathPuzzleType.numberPattern;
      case 'mathRiddle':
        return MathPuzzleType.mathRiddle;
      case 'logicGrid':
        return MathPuzzleType.logicGrid;
      default:
        return MathPuzzleType.symbolAlgebra;
    }
  }
}

class MathIQPuzzleData {
  final MathPuzzleType type;
  final String title;
  final String subtitle;
  final List<String> visualLines;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String hint;

  const MathIQPuzzleData({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.visualLines,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.hint,
  });

  factory MathIQPuzzleData.fromJson(Map<String, dynamic> json) {
    return MathIQPuzzleData(
      type: MathPuzzleType.fromString(json['type']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      visualLines: (json['visualLines'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      question: json['question']?.toString() ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation']?.toString() ?? '',
      hint: json['hint']?.toString() ?? '',
    );
  }
}

class MathPuzzleLevelData {
  final int levelNumber;
  final String title;
  final String description;
  final String icon;
  final List<MathIQPuzzleData> puzzles;

  const MathPuzzleLevelData({
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.puzzles,
  });

  factory MathPuzzleLevelData.fromJson(Map<String, dynamic> json) {
    final rawPuzzles = json['puzzles'] as List<dynamic>? ?? [];
    return MathPuzzleLevelData(
      levelNumber: json['levelNumber'] as int? ?? 1,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '🧮',
      puzzles: rawPuzzles
          .map((p) => MathIQPuzzleData.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Word Scramble Models ──────────────────────────────────────────────────────

class WordScramblePuzzleData {
  final String word;
  final String hint;
  final String emoji;
  final String category;

  const WordScramblePuzzleData({
    required this.word,
    required this.hint,
    required this.emoji,
    required this.category,
  });

  factory WordScramblePuzzleData.fromJson(Map<String, dynamic> json) {
    return WordScramblePuzzleData(
      word: (json['word']?.toString() ?? '').toUpperCase(),
      hint: json['hint']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🔤',
      category: json['category']?.toString() ?? '',
    );
  }
}

class WordScrambleLevelData {
  final int levelNumber;
  final String title;
  final String description;
  final String icon;
  final List<WordScramblePuzzleData> puzzles;

  const WordScrambleLevelData({
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.puzzles,
  });

  factory WordScrambleLevelData.fromJson(Map<String, dynamic> json) {
    final rawPuzzles = json['puzzles'] as List<dynamic>? ?? [];
    return WordScrambleLevelData(
      levelNumber: json['levelNumber'] as int? ?? 1,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '🔤',
      puzzles: rawPuzzles
          .map((p) => WordScramblePuzzleData.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ── Memory Match Models ───────────────────────────────────────────────────────

class MemoryMatchConfigData {
  final int pairsCount;
  final int crossAxisCount;
  final List<String> themeEmojis;
  final int maxMovesFor3Stars;
  final int maxMovesFor2Stars;
  final int? timeLimitSeconds;

  const MemoryMatchConfigData({
    required this.pairsCount,
    required this.crossAxisCount,
    required this.themeEmojis,
    required this.maxMovesFor3Stars,
    required this.maxMovesFor2Stars,
    this.timeLimitSeconds,
  });

  factory MemoryMatchConfigData.fromJson(Map<String, dynamic> json) {
    return MemoryMatchConfigData(
      pairsCount: json['pairsCount'] as int? ?? 2,
      crossAxisCount: json['crossAxisCount'] as int? ?? 2,
      themeEmojis: (json['themeEmojis'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['🦁', '🐼'],
      maxMovesFor3Stars: json['maxMovesFor3Stars'] as int? ?? 3,
      maxMovesFor2Stars: json['maxMovesFor2Stars'] as int? ?? 5,
      timeLimitSeconds: json['timeLimitSeconds'] as int?,
    );
  }
}

class MemoryMatchLevelData {
  final int levelNumber;
  final String title;
  final String description;
  final String icon;
  final MemoryMatchConfigData config;

  const MemoryMatchLevelData({
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.config,
  });

  factory MemoryMatchLevelData.fromJson(Map<String, dynamic> json) {
    return MemoryMatchLevelData(
      levelNumber: json['levelNumber'] as int? ?? 1,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '🃏',
      config: MemoryMatchConfigData.fromJson(
        (json['config'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}

// ── Game Submission Response ──────────────────────────────────────────────────

class GameSubmitResponse {
  final bool success;
  final String gameKey;
  final int levelNumber;
  final int stars;
  final int iqEarned;
  final int coinsEarned;
  final int nextLevelUnlocked;
  final int? userIq;
  final int? userCoins;
  final int? userStreak;

  const GameSubmitResponse({
    required this.success,
    required this.gameKey,
    required this.levelNumber,
    required this.stars,
    required this.iqEarned,
    required this.coinsEarned,
    required this.nextLevelUnlocked,
    this.userIq,
    this.userCoins,
    this.userStreak,
  });

  factory GameSubmitResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return GameSubmitResponse(
      success: json['success'] as bool? ?? false,
      gameKey: json['gameKey']?.toString() ?? '',
      levelNumber: json['levelNumber'] as int? ?? 1,
      stars: json['stars'] as int? ?? 1,
      iqEarned: json['iqEarned'] as int? ?? 0,
      coinsEarned: json['coinsEarned'] as int? ?? 0,
      nextLevelUnlocked: json['nextLevelUnlocked'] as int? ?? 1,
      userIq: user?['iq'] as int?,
      userCoins: user?['coins'] as int?,
      userStreak: user?['streak'] as int?,
    );
  }
}
