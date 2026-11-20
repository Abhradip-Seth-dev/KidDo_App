import 'package:kiddo_app/core/services/api_service.dart';

class FeaturesService {
  static final FeaturesService _instance = FeaturesService._internal();
  factory FeaturesService() => _instance;
  FeaturesService._internal();

  final ApiService _api = ApiService();

  // ── Adaptive Learning & Mascot ───────────────────────────────────────────────
  Future<Map<String, dynamic>?> getAdaptiveSuggestion() async {
    try {
      final res = await _api.get('/features/adaptive/suggestion');
      if (res.data['success'] == true) {
        return res.data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> recordAnswer({
    required String subject,
    required String topic,
    required bool isCorrect,
    required double responseTimeSeconds,
    String questionType = 'mcq',
  }) async {
    try {
      await _api.post('/features/adaptive/record-answer', data: {
        'subject': subject,
        'topic': topic,
        'isCorrect': isCorrect,
        'responseTimeSeconds': responseTimeSeconds,
        'questionType': questionType,
      });
    } catch (_) {}
  }

  /// Fetch all adaptive topics and student mastery
  Future<List<Map<String, dynamic>>?> getAdaptiveTopics() async {
    try {
      final res = await _api.get('/adaptive/topics');
      if (res.data['success'] == true && res.data['data'] is List) {
        return List<Map<String, dynamic>>.from(res.data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Start an adaptive learning session for a specific topic
  Future<Map<String, dynamic>?> startAdaptiveSession({
    required String topicId,
    String? subjectId,
  }) async {
    try {
      final payload = <String, dynamic>{'topicId': topicId};
      if (subjectId != null) payload['subjectId'] = subjectId;
      final res = await _api.post('/adaptive/sessions', data: payload);
      if (res.data['success'] == true) {
        return res.data['data'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fetch next question from server (anti-repetition, difficulty-matched, no answer key)
  Future<Map<String, dynamic>?> getNextAdaptiveQuestion({
    required String sessionId,
  }) async {
    try {
      final res = await _api.get('/adaptive/sessions/$sessionId/next-question');
      if (res.data['success'] == true) {
        if (res.data['isTopicMastered'] == true) {
          return {'isTopicMastered': true, 'message': res.data['message']};
        }
        return res.data['data'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Submit answer to server for verification, score transaction, and adaptive progression
  Future<Map<String, dynamic>?> submitAdaptiveAttempt({
    required String sessionId,
    required String questionId,
    required String submissionId,
    required dynamic selectedAnswer,
    int hintsUsed = 0,
    int durationSeconds = 0,
  }) async {
    try {
      final res = await _api.post('/adaptive/attempts', data: {
        'sessionId': sessionId,
        'questionId': questionId,
        'submissionId': submissionId,
        'selectedAnswer': selectedAnswer,
        'hintsUsed': hintsUsed,
        'durationSeconds': durationSeconds,
      });
      if (res.data['success'] == true) {
        return res.data['data'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get student's adaptive progress, topic mastery, and recommendations
  Future<Map<String, dynamic>?> getAdaptiveProgress() async {
    try {
      final res = await _api.get('/adaptive/progress');
      if (res.data['success'] == true) {
        return res.data['data'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Daily Challenges ────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getDailyChallenges() async {
    try {
      final res = await _api.get('/features/challenges/daily');
      if (res.data['success'] == true && res.data['challenges'] is List) {
        return List<Map<String, dynamic>>.from(res.data['challenges']);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> claimChallenge(String challengeId) async {
    try {
      final res = await _api.post('/features/challenges/claim', data: {
        'challengeId': challengeId,
      });
      if (res.data['success'] == true) {
        return res.data;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ── Boss Fight ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> submitBossFight({
    required String subject,
    required String chapter,
    required int score,
    required int livesRemaining,
    required int timeTakenSeconds,
  }) async {
    try {
      final res = await _api.post('/features/boss-fight/submit', data: {
        'subject': subject,
        'chapter': chapter,
        'score': score,
        'livesRemaining': livesRemaining,
        'timeTakenSeconds': timeTakenSeconds,
      });
      if (res.data['success'] == true) {
        return res.data;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ── Co-op Quest ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getCoopQuest() async {
    try {
      final res = await _api.get('/features/coop-quest');
      if (res.data['success'] == true) {
        return res.data['quest'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Friends & Friendly Leaderboard ──────────────────────────────────────────
  Future<Map<String, dynamic>> getFriendsData() async {
    try {
      final res = await _api.get('/features/friends');
      if (res.data['success'] == true) {
        return {
          'friends': res.data['friends'] ?? [],
          'pendingRequests': res.data['pendingRequests'] ?? [],
        };
      }
      return {'friends': [], 'pendingRequests': []};
    } catch (_) {
      return {'friends': [], 'pendingRequests': []};
    }
  }

  Future<String> sendFriendRequest(String email) async {
    final res = await _api.post('/features/friends/request', data: {
      'targetEmail': email,
    });
    return res.data['message'] ?? 'Friend request sent!';
  }

  Future<void> respondFriendRequest(String friendshipId, bool accept) async {
    await _api.post('/features/friends/respond', data: {
      'friendshipId': friendshipId,
      'accept': accept,
    });
  }

  Future<List<dynamic>> getFriendlyLeaderboard() async {
    try {
      final res = await _api.get('/features/friends/leaderboard');
      if (res.data['success'] == true) {
        return res.data['leaderboard'] ?? [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ── Social Activity Feed ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getFeed() async {
    try {
      final res = await _api.get('/features/social/feed');
      if (res.data['success'] == true) {
        return {
          'hasSubscription': res.data['hasSubscription'] == true,
          'posts': res.data['posts'] ?? [],
        };
      }
      return {'hasSubscription': false, 'posts': []};
    } catch (_) {
      return {'hasSubscription': false, 'posts': []};
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _api.post('/features/social/like', data: {'postId': postId});
    } catch (_) {}
  }

  Future<void> unlockFeedSubscription() async {
    await _api.post('/features/social/unlock-feed');
  }

  // ── Contests ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getContests() async {
    try {
      final res = await _api.get('/features/contests');
      if (res.data['success'] == true) {
        return {
          'contest': res.data['contest'],
          'isJoined': res.data['isJoined'] == true,
        };
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> joinContest(String contestId, {bool isAdEntry = false}) async {
    await _api.post('/features/contests/join', data: {
      'contestId': contestId,
      'isAdEntry': isAdEntry,
    });
  }

  // ── Parent Spectator Mode ───────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getParentMetrics() async {
    try {
      final res = await _api.get('/features/parent/metrics');
      if (res.data['success'] == true) {
        return res.data['parentData'];
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── Rewards & Virtual Economy ───────────────────────────────────────────────
  Future<void> claimDoubleReward(int baseIq, int baseCoins) async {
    await _api.post('/features/rewards/double-ad', data: {
      'baseIq': baseIq,
      'baseCoins': baseCoins,
    });
  }

  Future<void> buyStreakFreeze() async {
    await _api.post('/features/rewards/streak-freeze');
  }
}
