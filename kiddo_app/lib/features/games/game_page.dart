import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kiddo_app/core/providers/user_provider.dart';
import 'package:kiddo_app/core/theme/kiddo_colors.dart';
import 'package:kiddo_app/features/games/game_level_select_page.dart';
import 'package:kiddo_app/features/games/math_puzzle_game_page.dart';
import 'package:kiddo_app/features/games/word_scramble_game_page.dart';
import 'package:kiddo_app/features/games/memory_match_game_page.dart';

// ── Math Puzzle Levels ────────────────────────────────────────────────────────
const _kMathLevelList = [
  GameLevelData(levelNumber: 1, title: 'Apple Algebra', description: 'Single symbol logic', icon: '🍎'),
  GameLevelData(levelNumber: 2, title: 'Fives Parade', description: '2-symbol deduction', icon: '🍌'),
  GameLevelData(levelNumber: 3, title: 'Space Velocity', description: 'Doubling & order of ops', icon: '🚀'),
  GameLevelData(levelNumber: 4, title: 'Fruit Salad', description: '3-variable logic', icon: '🥗'),
  GameLevelData(levelNumber: 5, title: 'Square Matrix', description: 'Powers & Fibonacci', icon: '🧩'),
  GameLevelData(levelNumber: 6, title: 'Crowns & Gems', description: 'Alternating chains', icon: '👑'),
  GameLevelData(levelNumber: 7, title: 'Cube Matrix', description: 'Powers of 3 & primes', icon: '🧊'),
  GameLevelData(levelNumber: 8, title: 'Hero Power', description: 'Tricky word problems', icon: '🦸'),
  GameLevelData(levelNumber: 9, title: 'Power of Fives', description: 'Exponential logic', icon: '💎'),
  GameLevelData(levelNumber: 10, title: 'Grand Master', description: 'Magic squares & clock riddles', icon: '🏆'),
];

// ── Word Scramble Levels ──────────────────────────────────────────────────────
const _kWordLevelList = [
  GameLevelData(levelNumber: 1, title: 'Baby Animals', description: '3-letter words', icon: '🐱'),
  GameLevelData(levelNumber: 2, title: 'Night Sky', description: '4-letter words', icon: '⭐'),
  GameLevelData(levelNumber: 3, title: 'Sweet Orchard', description: '5-letter fruits', icon: '🍎'),
  GameLevelData(levelNumber: 4, title: 'Cosmic Voyage', description: 'Space & planets', icon: '🚀'),
  GameLevelData(levelNumber: 5, title: 'Wild Habitats', description: 'Nature & islands', icon: '🌴'),
  GameLevelData(levelNumber: 6, title: 'School Desk', description: 'Pencils & puzzles', icon: '✏️'),
  GameLevelData(levelNumber: 7, title: 'Cyber Zone', description: 'Robots & laptops', icon: '💻'),
  GameLevelData(levelNumber: 8, title: 'Melody Hall', description: 'Guitars & pianos', icon: '🎸'),
  GameLevelData(levelNumber: 9, title: 'Mythic Realm', description: 'Dragons & wizards', icon: '🐉'),
  GameLevelData(levelNumber: 10, title: 'Word Champion', description: '8-letter master vocabulary', icon: '🏆'),
];

// ── Memory Match Levels ───────────────────────────────────────────────────────
const _kMemoryLevelList = [
  GameLevelData(levelNumber: 1, title: 'Starter Zoo', description: '2x2 grid (2 pairs)', icon: '🦁'),
  GameLevelData(levelNumber: 2, title: 'Starlight Trio', description: '2x3 grid (3 pairs)', icon: '🚀'),
  GameLevelData(levelNumber: 3, title: 'Forest Friends', description: '2x4 grid (4 pairs)', icon: '🐰'),
  GameLevelData(levelNumber: 4, title: 'Fruit Blitz', description: '2x4 grid · 25s timer', icon: '🍓'),
  GameLevelData(levelNumber: 5, title: 'Orbit Galaxy', description: '3x4 grid (6 pairs)', icon: '🛸'),
  GameLevelData(levelNumber: 6, title: 'Yummy Snacks', description: '3x4 grid (6 pairs)', icon: '🍕'),
  GameLevelData(levelNumber: 7, title: 'Arcade Mania', description: '3x4 grid · 35s timer', icon: '🎮'),
  GameLevelData(levelNumber: 8, title: 'Silicon City', description: '4x4 grid (8 pairs)', icon: '🤖'),
  GameLevelData(levelNumber: 9, title: 'Stadium League', description: '4x4 grid (8 pairs)', icon: '⚽'),
  GameLevelData(levelNumber: 10, title: 'Crown Jewels', description: '4x4 grid · 45s speedrun', icon: '👑'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Game Hub Page
// ─────────────────────────────────────────────────────────────────────────────
class GamePage extends ConsumerWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;

    return Scaffold(
      backgroundColor: kScaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(user),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                physics: const BouncingScrollPhysics(),
                children: [
                  const Text(
                    'Featured Games',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Play progressive levels and unlock stars!',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  _buildGameCard(
                    context: context,
                    title: 'Math Puzzle',
                    description: '10 stages of logic algebra, patterns & riddles.',
                    emoji: '🧮',
                    category: '10 Levels',
                    color: kMathBlue,
                    delay: 0,
                    destination: GameLevelSelectPage(
                      gameTitle: 'Math Puzzle',
                      gameKey: 'math_puzzle',
                      emoji: '🧮',
                      gradientColors: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
                      levels: _kMathLevelList,
                      onStartLevel: (lvl) => MathPuzzleGamePage(levelNumber: lvl),
                    ),
                  ),
                  _buildGameCard(
                    context: context,
                    title: 'Word Scramble',
                    description: '10 stages of unscrambling letters to reveal words.',
                    emoji: '🔤',
                    category: '10 Levels',
                    color: kEnglishPurple,
                    delay: 100,
                    destination: GameLevelSelectPage(
                      gameTitle: 'Word Scramble',
                      gameKey: 'word_scramble',
                      emoji: '🔤',
                      gradientColors: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
                      levels: _kWordLevelList,
                      onStartLevel: (lvl) => WordScrambleGamePage(levelNumber: lvl),
                    ),
                  ),
                  _buildGameCard(
                    context: context,
                    title: 'Memory Match',
                    description: '10 stages of grid sizes, themes & speed challenges.',
                    emoji: '🃏',
                    category: '10 Levels',
                    color: kGold,
                    delay: 200,
                    destination: GameLevelSelectPage(
                      gameTitle: 'Memory Match',
                      gameKey: 'memory_match',
                      emoji: '🃏',
                      gradientColors: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                      levels: _kMemoryLevelList,
                      onStartLevel: (lvl) => MemoryMatchGamePage(levelNumber: lvl),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Games 🎮',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: kTextDark,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
          Row(
            children: [
              // Coins Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/coin.png',
                      height: 16,
                      width: 16,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${user?.coins ?? 0}',
                      style: const TextStyle(
                        color: Color(0xFFD97706),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // IQ Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/IQ.png',
                      height: 16,
                      width: 16,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${user?.iq ?? 0}',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required String description,
    required String emoji,
    required String category,
    required Color color,
    required int delay,
    required Widget destination,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: kCardWhite,
          borderRadius: BorderRadius.circular(kRadiusMd),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 70))
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.08, 1.08),
                      duration: 1500.ms,
                      curve: Curves.easeInOut,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: kTextDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: kTextGrey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1),
    );
  }
}
