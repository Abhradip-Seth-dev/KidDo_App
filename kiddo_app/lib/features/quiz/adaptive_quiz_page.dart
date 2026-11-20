import 'package:flutter/material.dart';
import 'package:kiddo_app/core/services/features_service.dart';
import 'package:kiddo_app/features/quiz/quiz_complete_page.dart';

class AdaptiveQuizPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final String? subjectId;

  const AdaptiveQuizPage({
    super.key,
    required this.topicId,
    required this.topicName,
    this.subjectId,
  });

  @override
  State<AdaptiveQuizPage> createState() => _AdaptiveQuizPageState();
}

class _AdaptiveQuizPageState extends State<AdaptiveQuizPage> {
  final FeaturesService _service = FeaturesService();
  static const int maxQuestions = 15;

  bool _isLoading = true;
  String? _sessionId;
  int _subjectScore = 100;
  double _topicMastery = 0.0;
  String _currentDifficulty = 'beginner';

  Map<String, dynamic>? _currentQuestion;
  String? _selectedOptionId;
  bool _isSubmitting = false;
  bool _hasChecked = false;
  Map<String, dynamic>? _lastResult;

  int _questionsAnswered = 0;
  int _questionsCorrect = 0;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  Future<void> _startSession() async {
    setState(() => _isLoading = true);
    final sessionData = await _service.startAdaptiveSession(
      topicId: widget.topicId,
      subjectId: widget.subjectId,
    );

    if (sessionData != null && mounted) {
      _sessionId = sessionData['sessionId'];
      _subjectScore = sessionData['subjectScore'] ?? 100;
      _topicMastery = (sessionData['topicMastery'] as num?)?.toDouble() ?? 0.0;
      _currentDifficulty = sessionData['currentDifficulty'] ?? 'beginner';
      await _loadNextQuestion();
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start adaptive session. Check connection.')),
        );
      }
    }
  }

  Future<void> _loadNextQuestion() async {
    if (_sessionId == null) return;
    if (_questionsAnswered >= maxQuestions) {
      _completePractice();
      return;
    }
    setState(() {
      _isLoading = true;
      _hasChecked = false;
      _selectedOptionId = null;
      _lastResult = null;
    });

    final qData = await _service.getNextAdaptiveQuestion(sessionId: _sessionId!);
    if (mounted) {
      if (qData == null || qData['isTopicMastered'] == true || qData['prompt'] == null) {
        _completePractice();
        return;
      }
      setState(() {
        _currentQuestion = qData;
        _isLoading = false;
      });
    }
  }

  void _completePractice() {
    final accuracy = _questionsAnswered > 0
        ? ((_questionsCorrect / _questionsAnswered) * 100).round()
        : 100;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizCompletePage(
          subjectName: widget.topicName,
          subjectColor: const Color(0xFF6366F1),
          totalPoints: _subjectScore,
          totalIQ: _questionsCorrect * 15,
          accuracy: accuracy,
        ),
      ),
    );
  }

  Future<void> _submitAnswer() async {
    if (_sessionId == null || _currentQuestion == null || _selectedOptionId == null || _isSubmitting || _hasChecked) {
      return;
    }

    setState(() => _isSubmitting = true);

    final submissionId = 'sub-${DateTime.now().millisecondsSinceEpoch}-${_currentQuestion!['questionId']}';
    final result = await _service.submitAdaptiveAttempt(
      sessionId: _sessionId!,
      questionId: _currentQuestion!['questionId'],
      submissionId: submissionId,
      selectedAnswer: {'option_id': _selectedOptionId},
      hintsUsed: 0,
      durationSeconds: 8,
    );

    if (result != null && mounted) {
      setState(() {
        _isSubmitting = false;
        _hasChecked = true;
        _lastResult = result;
        _questionsAnswered++;
        if (result['isCorrect'] == true) _questionsCorrect++;

        final scoreData = result['score'] as Map<String, dynamic>?;
        if (scoreData != null) {
          _subjectScore = scoreData['subjectScore'] ?? _subjectScore;
        }

        final progData = result['progress'] as Map<String, dynamic>?;
        if (progData != null) {
          _topicMastery = (progData['topicMastery'] as num?)?.toDouble() ?? _topicMastery;
          if (progData['recommendedDifficulty'] != null) {
            _currentDifficulty = progData['recommendedDifficulty'];
          }
        }
      });

      // Difficulty level-up alert
      final prog = result['progress'] as Map<String, dynamic>?;
      if (prog?['difficultyChanged'] == true) {
        final newDiff = prog?['recommendedDifficulty']?.toString().toUpperCase() ?? '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            content: Text('🌟 ADAPTIVE LEVEL UP! Scaled to $newDiff tier!'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Color _getDifficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'expert':
        return const Color(0xFFEF4444);
      case 'intermediate':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.topicName,
              style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Text(
              'AI Adaptive Practice (Anti-Repetition)',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF818CF8)),
              ),
              child: Text(
                '⭐ $_subjectScore pts',
                style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ),
          ),
          TextButton(
            onPressed: _completePractice,
            child: const Text(
              'Finish',
              style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentQuestion == null
              ? _buildExhaustedState()
              : _buildQuizBody(),
    );
  }

  Widget _buildQuizBody() {
    final prompt = _currentQuestion?['prompt'] ?? '';
    final options = (_currentQuestion?['options'] as List<dynamic>?) ?? [];
    final diff = _currentQuestion?['difficulty'] ?? _currentDifficulty;
    final diffColor = _getDifficultyColor(diff);
    final isMaxMastery = _topicMastery >= 100.0 && _currentDifficulty.toLowerCase() == 'expert';
    final isMaxQuestions = _questionsAnswered >= maxQuestions;
    final isSessionFinished = isMaxMastery || isMaxQuestions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Status Bar: Difficulty & Topic Mastery ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: diffColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: diffColor, width: 1.2),
                ),
                child: Text(
                  '● ${diff.toString().toUpperCase()}',
                  style: TextStyle(color: diffColor, fontWeight: FontWeight.w900, fontSize: 12),
                ),
              ),
              Text(
                'Mastery: ${_topicMastery.toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF475569)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_topicMastery / 100.0).clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFE2E8F0),
            color: diffColor,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 24),

          // ── Question Card ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${(_questionsAnswered + 1).clamp(1, maxQuestions)} of $maxQuestions',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w700, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  prompt,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Options List ──
          ...options.map((opt) {
            final optId = opt['option_id']?.toString() ?? '';
            final optText = opt['text']?.toString() ?? '';
            final isSelected = _selectedOptionId == optId;

            Color tileBg = Colors.white;
            Color tileBorder = const Color(0xFFE2E8F0);

            if (_hasChecked) {
              if (isSelected) {
                final isCorrect = _lastResult?['isCorrect'] == true;
                tileBg = isCorrect ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
                tileBorder = isCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
              }
            } else if (isSelected) {
              tileBg = const Color(0xFFEEF2FF);
              tileBorder = const Color(0xFF6366F1);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _hasChecked ? null : () => setState(() => _selectedOptionId = optId),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: tileBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: tileBorder, width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: isSelected ? tileBorder : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          optId,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          optText,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // ── Feedback Card (Explanation & Score Delta) ──
          if (_hasChecked && _lastResult != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _lastResult!['isCorrect'] == true ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _lastResult!['isCorrect'] == true ? const Color(0xFF86EFAC) : const Color(0xFFFECACA),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _lastResult!['isCorrect'] == true ? '🎉 Correct!' : '💡 Needs Practice',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: _lastResult!['isCorrect'] == true ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _lastResult!['score']?['pointsChange'] != null
                            ? '${_lastResult!['score']['pointsChange'] > 0 ? '+' : ''}${_lastResult!['score']['pointsChange']} pts'
                            : '',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: _lastResult!['isCorrect'] == true ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _lastResult!['feedback']?['explanation'] ?? '',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Topic Mastered Banner ──
          if (_hasChecked && isMaxMastery) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B)),
              ),
              child: const Row(
                children: [
                  Text('🏆', style: TextStyle(fontSize: 26)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Outstanding! You reached 100% Mastery at Expert Tier! Tap below to claim your IQ and finish.',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF92400E), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_hasChecked && isMaxQuestions) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF818CF8)),
              ),
              child: const Row(
                children: [
                  Text('🎯', style: TextStyle(fontSize: 26)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Awesome! You completed all 15 questions for this quiz session. Tap below to claim your rewards!',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3730A3), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Primary Action Button ──
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasChecked && isSessionFinished
                    ? const Color(0xFF10B981)
                    : const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: _hasChecked
                  ? (isSessionFinished ? _completePractice : _loadNextQuestion)
                  : _selectedOptionId != null && !_isSubmitting
                      ? _submitAnswer
                      : null,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _hasChecked
                          ? (isMaxMastery
                              ? '🏆 Claim 100% Mastery & Finish ➔'
                              : isMaxQuestions
                                  ? '🎉 Complete Quiz & Claim IQ ➔'
                                  : 'Next Question ➔')
                          : 'Check Answer',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExhaustedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            const Text(
              'Topic Mastered!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Outstanding! You have mastered ${widget.topicName} with ${_topicMastery.toStringAsFixed(1)}% Mastery at the Expert Tier!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _completePractice,
              child: const Text(
                'Claim IQ & Finish ➔',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
