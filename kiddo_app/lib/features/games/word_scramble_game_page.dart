import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiddo_app/core/models/game_models.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';
import 'package:kiddo_app/core/services/game_service.dart';
import 'package:kiddo_app/core/theme/kiddo_colors.dart';
import 'package:kiddo_app/features/games/widgets/game_victory_dialog.dart';

class WordScrambleGamePage extends ConsumerStatefulWidget {
  final int levelNumber;

  const WordScrambleGamePage({
    super.key,
    this.levelNumber = 1,
  });

  @override
  ConsumerState<WordScrambleGamePage> createState() => _WordScrambleGamePageState();
}

class _WordScrambleGamePageState extends ConsumerState<WordScrambleGamePage> {
  final Random _random = Random();
  final GameService _gameService = GameService();

  late int _currentLevel;
  WordScrambleLevelData? _levelData;
  bool _isLoading = true;
  String? _errorMessage;

  int _puzzleIndex = 0;
  int _score = 0;
  bool _isLevelComplete = false;

  int _iqEarned = 0;
  int _coinsEarned = 0;

  List<WordScramblePuzzleData> get _currentLevelPuzzles =>
      _levelData?.puzzles ?? [];

  WordScramblePuzzleData get _currentPuzzle => _currentLevelPuzzles[_puzzleIndex];

  late List<String> _availableLetters;
  late List<int?> _selectedLetterIndices;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.levelNumber;
    _availableLetters = [];
    _selectedLetterIndices = [];
    _fetchLevel(_currentLevel);
  }

  Future<void> _fetchLevel(int levelNum) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _puzzleIndex = 0;
      _score = 0;
      _isLevelComplete = false;
    });

    final data = await _gameService.getWordScrambleLevel(levelNum);
    if (!mounted) return;

    if (data != null && data.puzzles.isNotEmpty) {
      setState(() {
        _levelData = data;
        _currentLevel = levelNum;
        _isLoading = false;
      });
      _loadPuzzle(0);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load Word Scramble Level $levelNum. Please check your connection.';
      });
    }
  }

  void _loadPuzzle(int index) {
    if (_currentLevelPuzzles.isEmpty || index >= _currentLevelPuzzles.length) return;
    final puzzle = _currentLevelPuzzles[index];
    final letters = puzzle.word.split('');
    do {
      letters.shuffle(_random);
    } while (letters.join('') == puzzle.word && letters.length > 2);

    setState(() {
      _availableLetters = letters;
      _selectedLetterIndices = [];
      _isCorrect = null;
    });
  }

  void _onLetterTapped(int index) {
    if (_selectedLetterIndices.contains(index)) return;
    if (_selectedLetterIndices.length >= _currentPuzzle.word.length) return;

    setState(() {
      _selectedLetterIndices.add(index);
    });

    if (_selectedLetterIndices.length == _currentPuzzle.word.length) {
      _checkWord();
    }
  }

  void _onSlotTapped(int slotIndex) {
    if (slotIndex < _selectedLetterIndices.length) {
      setState(() {
        _selectedLetterIndices.removeAt(slotIndex);
        _isCorrect = null;
      });
    }
  }

  void _checkWord() {
    final formedWord =
        _selectedLetterIndices.map((i) => _availableLetters[i!]).join('');

    final correct = formedWord == _currentPuzzle.word;
    setState(() {
      _isCorrect = correct;
      if (correct) {
        _score += 25;
      }
    });

    if (correct) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        if (_puzzleIndex < _currentLevelPuzzles.length - 1) {
          setState(() {
            _puzzleIndex++;
            _loadPuzzle(_puzzleIndex);
          });
        } else {
          _finishLevel();
        }
      });
    }
  }

  Future<void> _finishLevel() async {
    final res = await _gameService.submitGameLevel(
      gameKey: 'word_scramble',
      levelNumber: _currentLevel,
      stars: 3,
      score: _score,
    );

    // Invalidate userProvider to update coins/IQ in the UI
    ref.invalidate(userProvider);

    if (res != null) {
      _iqEarned = res.iqEarned;
      _coinsEarned = res.coinsEarned;
    } else {
      _iqEarned = 30;
      _coinsEarned = 15;
    }

    setState(() {
      _isLevelComplete = true;
    });
  }

  void _shuffleLetters() {
    setState(() {
      _selectedLetterIndices.clear();
      _availableLetters.shuffle(_random);
      _isCorrect = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
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
              const Spacer(),
              _buildHintCard(),
              const SizedBox(height: 24),
              _buildWordSlots(),
              const Spacer(),
              _buildLetterChoices(),
              const SizedBox(height: 20),
              _buildActionControls(),
              const SizedBox(height: 24),
            ] else
              Expanded(
                child: GameVictoryDialog(
                  levelNumber: _currentLevel,
                  stars: 3,
                  iqEarned: _iqEarned,
                  coinsEarned: _coinsEarned,
                  subtitle: 'Great vocabulary skills! All words unscrambled!',
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
          const CircularProgressIndicator(color: Color(0xFF9B59B6)),
          const SizedBox(height: 16),
          Text(
            'Loading Word Scramble Level $_currentLevel...',
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
                backgroundColor: const Color(0xFF9B59B6),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFECE0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '⭐ $_score',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final total = _currentLevelPuzzles.isEmpty ? 1 : _currentLevelPuzzles.length;
    final progress = (_puzzleIndex + 1) / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                color: const Color(0xFF9B59B6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Word ${_puzzleIndex + 1}/$total',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard() {
    if (_currentLevelPuzzles.isEmpty) return const SizedBox();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF9B59B6).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B59B6).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(_currentPuzzle.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF9B59B6).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _currentPuzzle.category.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF9B59B6),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentPuzzle.hint,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildWordSlots() {
    if (_currentLevelPuzzles.isEmpty) return const SizedBox();
    final wordLength = _currentPuzzle.word.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(wordLength, (slotIndex) {
        final hasLetter = slotIndex < _selectedLetterIndices.length;
        final letter = hasLetter
            ? _availableLetters[_selectedLetterIndices[slotIndex]!]
            : '';

        Color slotColor = Colors.white;
        Color borderColor = const Color(0xFF9B59B6).withOpacity(0.4);

        if (_isCorrect == true) {
          slotColor = const Color(0xFF38EF7D);
          borderColor = const Color(0xFF11998E);
        } else if (_isCorrect == false && hasLetter) {
          slotColor = const Color(0xFFFF6B6B);
          borderColor = const Color(0xFFB00020);
        }

        return GestureDetector(
          onTap: () => _onSlotTapped(slotIndex),
          child: Container(
            width: 44,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: slotColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: (_isCorrect != null && hasLetter)
                      ? Colors.white
                      : const Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLetterChoices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(_availableLetters.length, (index) {
          final isUsed = _selectedLetterIndices.contains(index);
          final letter = _availableLetters[index];

          return GestureDetector(
            onTap: isUsed ? null : () => _onLetterTapped(index),
            child: AnimatedOpacity(
              opacity: isUsed ? 0.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 48,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9B59B6).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: _shuffleLetters,
          icon: const Icon(Icons.shuffle_rounded),
          tooltip: 'Shuffle',
        ),
        const SizedBox(width: 16),
        IconButton.filledTonal(
          onPressed: () {
            setState(() {
              _selectedLetterIndices.clear();
              _isCorrect = null;
            });
          },
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Clear',
        ),
      ],
    );
  }
}
