import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kiddo_app/core/models/game_models.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';
import 'package:kiddo_app/core/services/game_service.dart';
import 'package:kiddo_app/core/theme/kiddo_colors.dart';
import 'package:kiddo_app/features/games/widgets/game_victory_dialog.dart';

class _CardItem {
  final int id;
  final String emoji;
  bool isFlipped;
  bool isMatched;

  _CardItem({
    required this.id,
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class MemoryMatchGamePage extends ConsumerStatefulWidget {
  final int levelNumber;

  const MemoryMatchGamePage({
    super.key,
    this.levelNumber = 1,
  });

  @override
  ConsumerState<MemoryMatchGamePage> createState() => _MemoryMatchGamePageState();
}

class _MemoryMatchGamePageState extends ConsumerState<MemoryMatchGamePage> {
  final GameService _gameService = GameService();

  late int _currentLevel;
  MemoryMatchLevelData? _levelData;
  bool _isLoading = true;
  String? _errorMessage;

  late List<_CardItem> _cards;
  int? _firstFlippedIndex;
  int? _secondFlippedIndex;
  bool _isProcessing = false;
  int _moves = 0;
  int _matchedPairs = 0;
  int _secondsElapsed = 0;
  Timer? _timer;
  bool _isLevelComplete = false;

  int _iqEarned = 0;
  int _coinsEarned = 0;
  int _earnedStars = 1;

  MemoryMatchConfigData get _config =>
      _levelData?.config ??
      const MemoryMatchConfigData(
        pairsCount: 2,
        crossAxisCount: 2,
        themeEmojis: ['🦁', '🐼'],
        maxMovesFor3Stars: 3,
        maxMovesFor2Stars: 5,
      );

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.levelNumber;
    _cards = [];
    _fetchLevel(_currentLevel);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLevel(int levelNum) async {
    _timer?.cancel();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isLevelComplete = false;
      _secondsElapsed = 0;
      _moves = 0;
      _matchedPairs = 0;
    });

    final data = await _gameService.getMemoryMatchLevel(levelNum);
    if (!mounted) return;

    if (data != null) {
      setState(() {
        _levelData = data;
        _currentLevel = levelNum;
        _isLoading = false;
      });
      _startLevelGame();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load Memory Match Level $levelNum. Please check your connection.';
      });
    }
  }

  void _startLevelGame() {
    _timer?.cancel();
    _secondsElapsed = 0;
    _moves = 0;
    _matchedPairs = 0;
    _isLevelComplete = false;
    _firstFlippedIndex = null;
    _secondFlippedIndex = null;
    _isProcessing = false;

    final pool = List<String>.from(_config.themeEmojis)..shuffle();
    final chosen = pool.take(_config.pairsCount).toList();

    final List<_CardItem> cards = [];
    for (int i = 0; i < chosen.length; i++) {
      cards.add(_CardItem(id: i, emoji: chosen[i]));
      cards.add(_CardItem(id: i, emoji: chosen[i]));
    }
    cards.shuffle();

    setState(() {
      _cards = cards;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_isLevelComplete && !_isLoading) {
        setState(() {
          _secondsElapsed++;
          if (_config.timeLimitSeconds != null &&
              _secondsElapsed >= _config.timeLimitSeconds!) {
            _timer?.cancel();
            _onTimeOut();
          }
        });
      }
    });
  }

  void _onTimeOut() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⏰ Time\'s Up!'),
        content: const Text('You ran out of time! Give it another try.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startLevelGame();
            },
            child: const Text('Try Again 🔄'),
          ),
        ],
      ),
    );
  }

  void _onCardTapped(int index) {
    if (_isProcessing) return;
    if (_cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      _secondFlippedIndex = index;
      _moves++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    _isProcessing = true;
    final card1 = _cards[_firstFlippedIndex!];
    final card2 = _cards[_secondFlippedIndex!];

    if (card1.id == card2.id) {
      setState(() {
        card1.isMatched = true;
        card2.isMatched = true;
        _matchedPairs++;
        _firstFlippedIndex = null;
        _secondFlippedIndex = null;
        _isProcessing = false;
      });

      if (_matchedPairs == _config.pairsCount) {
        _timer?.cancel();
        _finishLevel();
      }
    } else {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            card1.isFlipped = false;
            card2.isFlipped = false;
            _firstFlippedIndex = null;
            _secondFlippedIndex = null;
            _isProcessing = false;
          });
        }
      });
    }
  }

  int _calculateStars() {
    if (_moves <= _config.maxMovesFor3Stars) return 3;
    if (_moves <= _config.maxMovesFor2Stars) return 2;
    return 1;
  }

  Future<void> _finishLevel() async {
    final stars = _calculateStars();
    _earnedStars = stars;

    final res = await _gameService.submitGameLevel(
      gameKey: 'memory_match',
      levelNumber: _currentLevel,
      stars: stars,
      moves: _moves,
      timeSeconds: _secondsElapsed,
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

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _isLevelComplete = true);
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
    _startLevelGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FBF6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            if (_isLoading)
              Expanded(child: _buildLoadingState())
            else if (_errorMessage != null)
              Expanded(child: _buildErrorState())
            else if (!_isLevelComplete) ...[
              _buildStatsBar(),
              const Spacer(),
              _buildCardGrid(),
              const Spacer(),
              const SizedBox(height: 20),
            ] else
              Expanded(
                child: GameVictoryDialog(
                  levelNumber: _currentLevel,
                  stars: _earnedStars,
                  iqEarned: _iqEarned,
                  coinsEarned: _coinsEarned,
                  subtitle: 'Cleared in $_moves moves and $_secondsElapsed seconds!',
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
          const CircularProgressIndicator(color: Color(0xFF11998E)),
          const SizedBox(height: 16),
          Text(
            'Loading Memory Match Level $_currentLevel...',
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
                backgroundColor: const Color(0xFF11998E),
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
                colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
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
            onPressed: _startLevelGame,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF11998E)),
            tooltip: 'Restart',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    String timeText =
        '${_secondsElapsed ~/ 60}:${(_secondsElapsed % 60).toString().padLeft(2, '0')}';
    if (_config.timeLimitSeconds != null) {
      final remaining = _config.timeLimitSeconds! - _secondsElapsed;
      timeText = '$remaining s';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatPill('Moves', '$_moves', Icons.touch_app_rounded, const Color(0xFF11998E)),
          _buildStatPill('Pairs', '$_matchedPairs/${_config.pairsCount}', Icons.check_circle_outline, Colors.orange),
          _buildStatPill('Time', timeText, Icons.timer_outlined, Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold)),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _config.crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          final isShown = card.isFlipped || card.isMatched;

          return GestureDetector(
            onTap: () => _onCardTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: isShown
                    ? (card.isMatched
                        ? const LinearGradient(
                            colors: [Color(0xFF38EF7D), Color(0xFF11998E)],
                          )
                        : const LinearGradient(
                            colors: [Colors.white, Color(0xFFF3F9FF)],
                          ))
                    : const LinearGradient(
                        colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(18),
                border: isShown && !card.isMatched
                    ? Border.all(color: const Color(0xFF11998E).withOpacity(0.4), width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF11998E).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: isShown
                    ? Text(
                        card.emoji,
                        style: const TextStyle(fontSize: 34),
                      ).animate().scale(curve: Curves.elasticOut)
                    : const Text(
                        '❓',
                        style: TextStyle(fontSize: 24, color: Colors.white70),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
