import 'package:flutter/material.dart';
import 'package:kiddo_app/core/theme/kiddo_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StreakCelebrationPage — "5 in a Row / 10 in a Row / 15 in a Row"
// ─────────────────────────────────────────────────────────────────────────────
class StreakCelebrationPage extends StatelessWidget {
  final int count; // 5, 10, or 15

  const StreakCelebrationPage({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: kPurpleLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left,
                          color: kPurple, size: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 18,
                      decoration: BoxDecoration(
                        color: kPurpleLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: kGoldLight,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/coin.png',
                          height: 16,
                          width: 16,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '5',
                          style: TextStyle(
                            color: kGold,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Big streak headline ────────────────────────────────
            Text(
              '$count IN A ROW',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: kOrange,
                fontFamily: 'Dongle',
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 24),

            // ── Mascot with sparkles ───────────────────────────────
            Stack(
              alignment: Alignment.center,
              children: [
                // Background glow
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kGoldLight.withOpacity(0.5),
                  ),
                ),
                // Confetti dots
                for (final pos in [
                  [-70.0, -30.0],
                  [60.0, -50.0],
                  [-50.0, 60.0],
                  [80.0, 40.0],
                ])
                  Positioned(
                    left: 100 + pos[0],
                    top: 100 + pos[1],
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: kGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                // Character
                Image.asset(
                  'assets/images/kido_character.png',
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ],
            ),

            const Spacer(),

            // ── Continue button ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Stack(
                  children: [
                    Container(
                      height: 58 + 6,
                      decoration: BoxDecoration(
                        color: kPurpleShadow,
                        borderRadius: BorderRadius.circular(kRadiusLg),
                      ),
                    ),
                    Container(
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPurpleMid, kPurple],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(kRadiusLg),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'CONTINUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
