import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';
import 'package:kiddo_app/core/services/features_service.dart';

class BossFightPage extends ConsumerStatefulWidget {
  final String subject;
  final String chapter;

  const BossFightPage({
    super.key,
    this.subject = 'Math',
    this.chapter = 'Chapter 1: Boss Battle',
  });

  @override
  ConsumerState<BossFightPage> createState() => _BossFightPageState();
}

class _BossFightPageState extends ConsumerState<BossFightPage>
    with SingleTickerProviderStateMixin {
  int _lives = 3;
  int _secondsLeft = 180; // 3 minutes
  Timer? _timer;

  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  bool _isFinished = false;
  bool _won = false;
  bool _isDoublingReward = false;
  bool _rewardDoubled = false;

  late AnimationController _shakeController;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is 15 + 27?',
      'options': ['32', '42', '45', '52'],
      'correct': 1,
    },
    {
      'question': 'If a triangle has 3 sides, how many sides do 4 triangles have?',
      'options': ['7', '10', '12', '16'],
      'correct': 2,
    },
    {
      'question': 'What is 100 - 37?',
      'options': ['63', '73', '57', '67'],
      'correct': 0,
    },
    {
      'question': 'Which number is an EVEN number?',
      'options': ['17', '29', '34', '51'],
      'correct': 2,
    },
    {
      'question': 'What is 8 × 7?',
      'options': ['54', '56', '58', '64'],
      'correct': 1,
    },
    {
      'question': 'Half of 50 is:',
      'options': ['20', '25', '30', '35'],
      'correct': 1,
    },
    {
      'question': 'What is 72 ÷ 8?',
      'options': ['7', '8', '9', '10'],
      'correct': 2,
    },
    {
      'question': 'How many minutes are in 2 hours?',
      'options': ['100', '120', '150', '200'],
      'correct': 1,
    },
    {
      'question': 'What is 9 × 9?',
      'options': ['72', '81', '90', '99'],
      'correct': 1,
    },
    {
      'question': 'Solve: 5 + 5 × 2 = ?',
      'options': ['20', '15', '10', '25'],
      'correct': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _endGame(won: false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleOptionSelect(int index) {
    if (_isAnswered || _isFinished) return;

    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
    });

    final currentQ = _questions[_currentQuestionIndex];
    final isCorrect = index == currentQ['correct'];

    if (isCorrect) {
      _score++;
    } else {
      _shakeController.forward(from: 0.0);
      _lives--;
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      if (_lives <= 0) {
        _endGame(won: false);
        return;
      }

      if (_currentQuestionIndex + 1 < _questions.length) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOptionIndex = null;
          _isAnswered = false;
        });
      } else {
        _endGame(won: _score >= 7);
      }
    });
  }

  void _endGame({required bool won}) {
    _timer?.cancel();
    setState(() {
      _isFinished = true;
      _won = won;
    });

    final timeTaken = 180 - _secondsLeft;
    FeaturesService().submitBossFight(
      subject: widget.subject,
      chapter: widget.chapter,
      score: _score,
      livesRemaining: _lives,
      timeTakenSeconds: timeTaken,
    ).then((_) {
      ref.invalidate(userProvider);
    }).catchError((_) {});
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildResultScreen();
    }

    final bossHealthRatio = (10 - _score) / 10.0;
    final currentQ = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Arena Theme
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: Lives & 3-Min Timer ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  // Timer Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _secondsLeft < 30 ? Colors.redAccent : const Color(0xFF38BDF8),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 18,
                          color: _secondsLeft < 30 ? Colors.redAccent : const Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(_secondsLeft),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _secondsLeft < 30 ? Colors.redAccent : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lives Hearts (3 Lives)
                  Row(
                    children: List.generate(3, (index) {
                      final hasLife = index < _lives;
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          hasLife ? '❤️' : '🖤',
                          style: const TextStyle(fontSize: 22),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // ── Boss Card ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF831843), Color(0xFFBE185D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('🐉', style: TextStyle(fontSize: 48)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.subject} Titan Boss',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Defeat to conquer ${widget.chapter}!',
                                style: const TextStyle(
                                  color: Color(0xFFFBCFE8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Boss HP Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'BOSS HEALTH',
                              style: TextStyle(
                                color: Color(0xFFFDE047),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${(bossHealthRatio * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: bossHealthRatio,
                            minHeight: 12,
                            backgroundColor: const Color(0xFF500724),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Question Tracker ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUESTION ${_currentQuestionIndex + 1} / ${_questions.length}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Hits: $_score/10',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Question Box ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF334155), width: 1.5),
                      ),
                      child: Text(
                        currentQ['question'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Options
                    ...List.generate(
                      (currentQ['options'] as List).length,
                      (index) => _buildOptionButton(index, currentQ['options'][index], currentQ['correct']),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index, String optionText, int correctIndex) {
    Color cardColor = const Color(0xFF1E293B);
    Color borderColor = const Color(0xFF334155);
    Color textColor = Colors.white;

    if (_isAnswered) {
      if (index == correctIndex) {
        cardColor = const Color(0xFF065F46);
        borderColor = const Color(0xFF10B981);
      } else if (index == _selectedOptionIndex) {
        cardColor = const Color(0xFF881337);
        borderColor = const Color(0xFFF43F5E);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _handleOptionSelect(index),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            optionText,
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _won ? '👑' : '💥',
                  style: const TextStyle(fontSize: 72),
                ),
                const SizedBox(height: 16),
                Text(
                  _won ? 'VICTORY!' : 'DEFEATED!',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: _won ? const Color(0xFF38BDF8) : const Color(0xFFF43F5E),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _won
                      ? 'You successfully brought down the Boss!'
                      : 'The boss was too tough this time. Try again!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Rewards Card
                if (_won)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Image.asset('assets/images/IQ.png', height: 32, width: 32),
                            const SizedBox(height: 6),
                            Text(
                              '+${_rewardDoubled ? 300 : 150} IQ',
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset('assets/images/coin.png', height: 32, width: 32),
                            const SizedBox(height: 6),
                            Text(
                              '+${_rewardDoubled ? 100 : 50} Coins',
                              style: const TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // 2x Reward Ad Button (Section 2.7)
                if (_won && !_rewardDoubled)
                  GestureDetector(
                    onTap: _isDoublingReward
                        ? null
                        : () async {
                            setState(() => _isDoublingReward = true);
                            try {
                              await FeaturesService().claimDoubleReward(150, 50);
                              ref.invalidate(userProvider);
                              setState(() {
                                _rewardDoubled = true;
                                _isDoublingReward = false;
                              });
                            } catch (_) {
                              setState(() => _isDoublingReward = false);
                            }
                          },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.play_circle_fill, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Watch Ad for 2x Reward 🎁',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 14),

                // Continue button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Back to Lessons',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
