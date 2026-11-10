import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kiddo_app/core/models/game_models.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';
import 'package:kiddo_app/core/services/game_service.dart';
import 'package:kiddo_app/core/theme/kiddo_colors.dart';
import 'package:kiddo_app/features/games/widgets/game_victory_dialog.dart';

class MathPuzzleGamePage extends ConsumerStatefulWidget {
  final int levelNumber;

  const MathPuzzleGamePage({
    super.key,
    this.levelNumber = 1,
  });

  @override
  ConsumerState<MathPuzzleGamePage> createState() => _MathPuzzleGamePageState();
}

class _MathPuzzleGamePageState extends ConsumerState<MathPuzzleGamePage> {
  final GameService _gameService = GameService();

  late int _currentLevel;
  MathPuzzleLevelData? _levelData;
  bool _isLoading = true;
  String? _errorMessage;

  int _puzzleIndex = 0;
  int _correctCount = 0;
  int _score = 0;
  int? _selectedOption;
  bool? _isCorrect;
  bool _showExplanation = false;
  bool _isLevelComplete = false;

  int _iqEarned = 0;
  int _coinsEarned = 0;
  int _earnedStars = 1;

  List<MathIQPuzzleData> get _currentLevelPuzzles =>
      _levelData?.puzzles ?? [];

  MathIQPuzzleData get _currentPuzzle => _currentLevelPuzzles[_puzzleIndex];

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.levelNumber;
    _fetchLevel(_currentLevel);
  }

  Future<void> _fetchLevel(int levelNum) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _puzzleIndex = 0;
      _correctCount = 0;
      _score = 0;
      _selectedOption = null;
      _isCorrect = null;
      _showExplanation = false;
      _isLevelComplete = false;
    });

    final data = await _gameService.getMathPuzzleLevel(levelNum);
    if (!mounted) return;

    if (data != null && data.puzzles.isNotEmpty) {
      setState(() {
        _levelData = data;
        _currentLevel = levelNum;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load Math Puzzle Level $levelNum. Please check your connection.';
      });
    }
  }

  void _onOptionSelected(int index) {
    if (_selectedOption != null) return;

    final correct = index == _currentPuzzle.correctIndex;
    setState(() {
      _selectedOption = index;
      _isCorrect = correct;
      _showExplanation = true;
      if (correct) {
        _score += 25;
        _correctCount++;
      }
    });
  }

  void _nextPuzzle() {
    if (_puzzleIndex < _currentLevelPuzzles.length - 1) {
      setState(() {
        _puzzleIndex++;
        _selectedOption = null;
        _isCorrect = null;
        _showExplanation = false;
      });
    } else {
      _finishLevel();
    }
  }

  Future<void> _finishLevel() async {
    final total = _currentLevelPuzzles.length;
    int stars = 1;
    if (_correctCount == total) {
      stars = 3;
    } else if (_correctCount >= 2) {
      stars = 2;
    }

    _earnedStars = stars;

    // Submit to database
    final res = await _gameService.submitGameLevel(
      gameKey: 'math_puzzle',
      levelNumber: _currentLevel,
      stars: stars,
      score: _score,
    );

    // Invalidate userProvider to update coins/IQ in the UI
    ref.invalidate(userProvider);

    if (res != null) {
      _iqEarned = res.iqEarned;
      _coinsEarned = res.coinsEarned;
    } else {
      _iqEarned = stars * 10;
      _coinsEarned = stars * 5;
    }

    setState(() {
      _isLevelComplete = true;
    });
  }

  void _startNextLevel() {
    if (_currentLevel < 10) {
      _fetchLevel(_currentLevel + 1);
    } else {
      Navigator.pop(context);
    }
  }

  void _retryLevel() {
    _fetchLevel(_currentLevel);
  }

  void _showHintDialog() {
    if (_levelData == null || _currentLevelPuzzles.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('💡', style: TextStyle(fontSize: 26)),
            SizedBox(width: 8),
            Text('IQ Hint', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          _currentPuzzle.hint,
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FD),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            if (_isLoading)
              Expanded(child: _buildLoadingState())
            else if (_errorMessage != null)
              Expanded(child: _buildErrorState())
            else if (!_isLevelComplete) ...[
              _buildProgressBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      _buildPuzzleHeader(),
                      const SizedBox(height: 14),
                      _buildVisualBoard(),
                      const SizedBox(height: 18),
                      _buildQuestionPrompt(),
                      const SizedBox(height: 16),
                      _buildOptionsList(),
                      if (_showExplanation) ...[
                        const SizedBox(height: 16),
                        _buildExplanationCard(),
                      ],
                    ],
                  ),
                ),
              ),
              _buildBottomAction(),
            ] else
              Expanded(
                child: GameVictoryDialog(
                  levelNumber: _currentLevel,
                  stars: _earnedStars,
                  iqEarned: _iqEarned,
                  coinsEarned: _coinsEarned,
                  subtitle: 'You solved $_correctCount of ${_currentLevelPuzzles.length} puzzles correctly!',
                  onReplay: _retryLevel,
                  onNextLevel: _startNextLevel,
                  hasNextLevel: _currentLevel < 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: kPurple),
          const SizedBox(height: 16),
          Text(
            'Loading Level $_currentLevel...',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: kTextGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.orange),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Failed to load level',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: kTextDark),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _fetchLevel(_currentLevel),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: kTextDark),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Level $_currentLevel',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          IconButton(
            onPressed: _showHintDialog,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAA7).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Text('💡', style: TextStyle(fontSize: 18)),
            ),
            tooltip: 'Hint',
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final total = _currentLevelPuzzles.isEmpty ? 1 : _currentLevelPuzzles.length;
    final progress = (_puzzleIndex + 1) / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey[200],
                color: const Color(0xFF6C63FF),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_puzzleIndex + 1}/$total',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleHeader() {
    return Column(
      children: [
        Text(
          _currentPuzzle.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _currentPuzzle.subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildVisualBoard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: _currentPuzzle.visualLines
            .map(
              (line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  line,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    ).animate(key: ValueKey('$_currentLevel$_puzzleIndex')).scale(duration: 250.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildQuestionPrompt() {
    return Text(
      _currentPuzzle.question,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A2E),
      ),
    );
  }

  Widget _buildOptionsList() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: List.generate(_currentPuzzle.options.length, (index) {
        final option = _currentPuzzle.options[index];
        final isSelected = _selectedOption == index;
        final isCorrectOption = index == _currentPuzzle.correctIndex;

        Color bgColor = Colors.white;
        Color borderColor = Colors.grey[200]!;
        Color textColor = const Color(0xFF1A1A2E);

        if (_selectedOption != null) {
          if (isCorrectOption) {
            bgColor = const Color(0xFF38EF7D);
            borderColor = const Color(0xFF11998E);
            textColor = Colors.white;
          } else if (isSelected) {
            bgColor = const Color(0xFFFF6B6B);
            borderColor = const Color(0xFFB00020);
            textColor = Colors.white;
          }
        }

        return GestureDetector(
          onTap: () => _onOptionSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildExplanationCard() {
    final isCorrect = _isCorrect == true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFE8F8F0) : const Color(0xFFFFEDED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCorrect ? const Color(0xFF38EF7D) : const Color(0xFFFF6B6B),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                color: isCorrect ? const Color(0xFF11998E) : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Brilliant Logic! 🎉' : 'Tricky, isn\'t it? 💡',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isCorrect ? const Color(0xFF11998E) : Colors.red[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _currentPuzzle.explanation,
            style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey[800]),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildBottomAction() {
    if (!_showExplanation) return const SizedBox(height: 20);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: ElevatedButton(
        onPressed: _nextPuzzle,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          _puzzleIndex < _currentLevelPuzzles.length - 1 ? 'Next Puzzle ➔' : 'Complete Level 🏆',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    ).animate().fadeIn();
  }
}
