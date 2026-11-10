import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kiddo_app/core/services/api_service.dart';

/// Offline fallback service (Section 2.8):
/// Caches the next 5 micro-lessons/quizzes locally and flushes
/// pending quiz completions to backend when online.
class OfflineCacheService {
  static const String _cachedLessonsKey = 'kiddo_cached_micro_lessons';
  static const String _pendingCompletionsKey = 'kiddo_pending_offline_completions';

  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  /// Cache upcoming micro-lessons
  Future<void> cacheLessons(String subject, List<dynamic> lessons) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(lessons);
    await prefs.setString('${_cachedLessonsKey}_$subject', jsonStr);
  }

  /// Read cached lessons for offline play
  Future<List<dynamic>> getCachedLessons(String subject) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('${_cachedLessonsKey}_$subject');
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      return jsonDecode(jsonStr) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  /// Queue an offline completion outcome
  Future<void> queueOfflineAttempt({
    required String subject,
    required int unitNumber,
    required String quizName,
    required int correctCount,
    required int totalQuestions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existingListStr = prefs.getString(_pendingCompletionsKey) ?? '[]';
    final List<dynamic> existingList = jsonDecode(existingListStr);

    existingList.add({
      'subject': subject,
      'unitNumber': unitNumber,
      'quizName': quizName,
      'correctCount': correctCount,
      'totalQuestions': totalQuestions,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await prefs.setString(_pendingCompletionsKey, jsonEncode(existingList));
  }

  /// Flush pending completions to backend when reconnected
  Future<int> syncPendingAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final existingListStr = prefs.getString(_pendingCompletionsKey);
    if (existingListStr == null || existingListStr.isEmpty) return 0;

    List<dynamic> pending;
    try {
      pending = jsonDecode(existingListStr);
    } catch (_) {
      return 0;
    }

    if (pending.isEmpty) return 0;

    int syncedCount = 0;
    final List<dynamic> remaining = [];

    for (final item in pending) {
      try {
        await ApiService().post('/quiz/submit', data: {
          'subject': item['subject'],
          'unitNumber': item['unitNumber'],
          'quizName': item['quizName'],
          'correctCount': item['correctCount'],
          'totalQuestions': item['totalQuestions'],
        });
        syncedCount++;
      } catch (e) {
        remaining.add(item);
      }
    }

    await prefs.setString(_pendingCompletionsKey, jsonEncode(remaining));
    return syncedCount;
  }
}
