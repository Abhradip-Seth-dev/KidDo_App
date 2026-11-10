import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kiddo_app/core/services/game_service.dart';
import 'package:kiddo_app/features/games/game_progress_service.dart';

class GameLevelData {
  final int levelNumber;
  final String title;
  final String description;
  final String icon;

  const GameLevelData({
    required this.levelNumber,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class GameLevelSelectPage extends StatefulWidget {
  final String gameTitle;
  final String gameKey;
  final String emoji;
  final List<Color> gradientColors;
  final List<GameLevelData> levels;
  final Widget Function(int levelNumber) onStartLevel;

  const GameLevelSelectPage({
    super.key,
    required this.gameTitle,
    required this.gameKey,
    required this.emoji,
    required this.gradientColors,
    required this.levels,
    required this.onStartLevel,
  });

  @override
  State<GameLevelSelectPage> createState() => _GameLevelSelectPageState();
}

class _GameLevelSelectPageState extends State<GameLevelSelectPage> {
  Map<int, int> _levelStars = {};
  int _highestUnlocked = 1;
  int _totalStars = 0;
  bool _isLoading = true;
  List<GameLevelData> _activeLevels = [];

  @override
  void initState() {
    super.initState();
    _activeLevels = widget.levels;
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final Map<int, int> stars = {};
    for (final level in _activeLevels) {
      stars[level.levelNumber] = await GameProgressService.getLevelStars(
        widget.gameKey,
        level.levelNumber,
      );
    }
    int unlocked = await GameProgressService.getHighestUnlockedLevel(widget.gameKey);
    int total = await GameProgressService.getTotalStars(widget.gameKey, _activeLevels.length);

    try {
      final remoteLevels = await GameService().getGameLevels(widget.gameKey);
      if (remoteLevels.isNotEmpty) {
        _activeLevels = remoteLevels.map((l) => GameLevelData(
          levelNumber: l.levelNumber,
          title: l.title,
          description: l.description,
          icon: l.icon,
        )).toList();

        for (final l in remoteLevels) {
          if (l.stars > (stars[l.levelNumber] ?? 0)) {
            stars[l.levelNumber] = l.stars;
            await GameProgressService.saveLevelStars(widget.gameKey, l.levelNumber, l.stars);
          }
        }
        unlocked = await GameProgressService.getHighestUnlockedLevel(widget.gameKey);
        total = await GameProgressService.getTotalStars(widget.gameKey, _activeLevels.length);
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _levelStars = stars;
        _highestUnlocked = unlocked;
        _totalStars = total;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.gradientColors[0];
    final maxStars = _activeLevels.length * 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      body: Stack(
        children: [
          // ── Gradient Header ───────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // ── Top Navigation Bar ────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 16,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.emoji} ${widget.gameTitle}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Star Counter Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '$_totalStars / $maxStars',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Levels Grid ───────────────────────────────────────────────────
          Positioned.fill(
            top: 140,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: Container(
                color: const Color(0xFFF6F8FD),
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: primaryColor))
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: _activeLevels.length,
                        itemBuilder: (context, index) {
                          final level = _activeLevels[index];
                          final stars = _levelStars[level.levelNumber] ?? 0;
                          final isUnlocked = level.levelNumber <= _highestUnlocked;
                          final isCurrent = level.levelNumber == _highestUnlocked;

                          return _LevelCard(
                            level: level,
                            stars: stars,
                            isUnlocked: isUnlocked,
                            isCurrent: isCurrent,
                            primaryColor: primaryColor,
                            gradientColors: widget.gradientColors,
                            onTap: () async {
                              if (isUnlocked) {
                                await Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (_) => widget.onStartLevel(level.levelNumber),
                                  ),
                                );
                                _loadProgress(); // Refresh when returning
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🔒 Complete previous levels to unlock!'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final GameLevelData level;
  final int stars;
  final bool isUnlocked;
  final bool isCurrent;
  final Color primaryColor;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.stars,
    required this.isUnlocked,
    required this.isCurrent,
    required this.primaryColor,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isCurrent
                ? primaryColor
                : (stars > 0 ? const Color(0xFF38EF7D) : Colors.grey[200]!),
            width: isCurrent ? 2.5 : (stars > 0 ? 2 : 1.5),
          ),
          boxShadow: [
            BoxShadow(
              color: isCurrent
                  ? primaryColor.withOpacity(0.2)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? primaryColor.withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'LVL ${level.levelNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isUnlocked ? primaryColor : Colors.grey,
                          ),
                        ),
                      ),
                      Text(level.icon, style: const TextStyle(fontSize: 22)),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    level.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? const Color(0xFF1A1A2E) : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  // Stars or Lock Icon
                  if (!isUnlocked)
                    Row(
                      children: [
                        Icon(Icons.lock_rounded, size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          'Locked',
                          style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w600),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: List.generate(
                        3,
                        (i) => Icon(
                          Icons.star_rounded,
                          size: 20,
                          color: i < stars ? Colors.amber : Colors.grey[200],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Current Level Pulse Badge
            if (isCurrent)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.6, 1.6),
                      duration: 800.ms,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
