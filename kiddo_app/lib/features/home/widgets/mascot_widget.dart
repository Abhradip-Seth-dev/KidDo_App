import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MascotState — defines what emotional state the KIDO mascot is in.
// Driven by quiz streak count from QuizState.consecutiveCorrect.
// ─────────────────────────────────────────────────────────────────────────────
enum MascotState {
  idle,    // Normal browsing / home screen
  happy,   // Correct answer, streak 1–4
  excited, // Streak milestone (5+)
  sad,     // Wrong answer
}

// ─────────────────────────────────────────────────────────────────────────────
// MascotWidget — animated KIDO mascot using flutter_animate.
// Accepts a [state] to drive different animations.
// ─────────────────────────────────────────────────────────────────────────────
class MascotWidget extends StatelessWidget {
  final MascotState state;
  final double size;

  const MascotWidget({
    super.key,
    this.state = MascotState.idle,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: _buildAnimatedMascot(),
    );
  }

  Widget _buildAnimatedMascot() {
    final image = Image.asset(
      'assets/images/kido_character.png',
      fit: BoxFit.contain,
    );

    switch (state) {
      case MascotState.idle:
        // Gentle floating bob — always present on Home screen
        return image
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(
              begin: 0,
              end: -8,
              duration: 1800.ms,
              curve: Curves.easeInOut,
            );

      case MascotState.happy:
        // Bounce up with a little spin — correct answer
        return image
            .animate()
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.15, 1.15),
              duration: 300.ms,
              curve: Curves.elasticOut,
            )
            .then()
            .scale(
              begin: const Offset(1.15, 1.15),
              end: const Offset(1, 1),
              duration: 200.ms,
            )
            .shake(hz: 3, offset: const Offset(0, -6), duration: 400.ms);

      case MascotState.excited:
        // Big celebration — streak milestone
        return image
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.2, 1.2),
              duration: 400.ms,
              curve: Curves.elasticOut,
            )
            .shimmer(
              duration: 800.ms,
              color: Colors.amber.withOpacity(0.5),
            )
            .shake(hz: 5, offset: const Offset(4, 0));

      case MascotState.sad:
        // Droop down — wrong answer
        return image
            .animate()
            .moveY(
              begin: 0,
              end: 10,
              duration: 400.ms,
              curve: Curves.easeIn,
            )
            .fadeOut(begin: 1.0, duration: 200.ms)
            .then()
            .fadeIn(duration: 300.ms)
            .moveY(begin: 10, end: 0, duration: 300.ms);
    }
  }
}
