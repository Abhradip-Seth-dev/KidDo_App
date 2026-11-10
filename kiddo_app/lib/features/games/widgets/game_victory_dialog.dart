import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kiddo_app/core/theme/kiddo_colors.dart';

class GameVictoryDialog extends StatelessWidget {
  final int levelNumber;
  final int stars;
  final int iqEarned;
  final int coinsEarned;
  final String subtitle;
  final VoidCallback onReplay;
  final VoidCallback onNextLevel;
  final bool hasNextLevel;

  const GameVictoryDialog({
    super.key,
    required this.levelNumber,
    required this.stars,
    required this.iqEarned,
    required this.coinsEarned,
    required this.subtitle,
    required this.onReplay,
    required this.onNextLevel,
    this.hasNextLevel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy / celebration badge
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: kGoldLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: kGold.withOpacity(0.4), width: 3),
                ),
                child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 48)),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

              const SizedBox(height: 16),
              Text(
                'Level $levelNumber Cleared!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: kTextDark,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kTextGrey,
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 18),
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final filled = i < stars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star_rounded,
                      size: 48,
                      color: filled ? Colors.amber : Colors.grey[300],
                    )
                        .animate(delay: (350 + i * 150).ms)
                        .scale(curve: Curves.elasticOut),
                  );
                }),
              ),

              const SizedBox(height: 20),
              // Rewards Card (+IQ and +Coins)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: kPurpleLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: kPurpleMid.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/IQ.png',
                          height: 24,
                          width: 24,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'IQ Earned',
                              style: TextStyle(fontSize: 11, color: kTextGrey, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '+$iqEarned IQ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: kPurple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(height: 32, width: 1, color: Colors.grey[300]),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/coin.png',
                          height: 24,
                          width: 24,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Coins Earned',
                              style: TextStyle(fontSize: 11, color: kTextGrey, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '+$coinsEarned Coins',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: kGold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

              const SizedBox(height: 28),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReplay,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: kBorderGrey, width: 1.5),
                      ),
                      child: const Text(
                        'Replay 🔄',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: kTextDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onNextLevel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        hasNextLevel ? 'Next Level ➔' : 'Done 🏁',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
