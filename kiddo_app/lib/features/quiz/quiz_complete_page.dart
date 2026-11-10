import 'package:flutter/material.dart';
import 'package:kiddo_app/core/theme/kiddo_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared base for QuizCompletePage & LessonCompletePage
// ─────────────────────────────────────────────────────────────────────────────
class _CelebrationBase extends StatelessWidget {
  final String title;
  final String subtitle;
  final int totalPoints;
  final int totalIQ;
  final int accuracy;
  final String buttonLabel;
  final VoidCallback onButton;

  const _CelebrationBase({
    required this.title,
    required this.subtitle,
    required this.totalPoints,
    required this.totalIQ,
    required this.accuracy,
    required this.buttonLabel,
    required this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // ── Celebration illustration ──────────────────────────
              SizedBox(
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sparkle decorations
                    const Positioned(
                        top: 10, left: 30,
                        child: _Sparkle(color: Color(0xffffe066))),
                    const Positioned(
                        top: 20, right: 40,
                        child: _Sparkle(color: Color(0xff6de88a), size: 22)),
                    const Positioned(
                        bottom: 40, left: 50,
                        child: _Sparkle(color: Color(0xffc084fc), size: 18)),
                    const Positioned(
                        top: 50, right: 20,
                        child: _Sparkle(color: Color(0xffffe066), size: 16)),
                    // Mascot / character
                    Image.asset(
                      'assets/images/kido_character.png',
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Carousel dots (page indicator look) ───────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Dot(active: true),
                  const SizedBox(width: 6),
                  _Dot(active: false),
                ],
              ),

              const SizedBox(height: 20),

              // ── Title ─────────────────────────────────────────────
              Text(
                title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: kOrange,
                  fontFamily: 'Dongle',
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 6),

              // ── Subtitle ──────────────────────────────────────────
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: kTextGrey,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // ── Stats row (3 cards) ───────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'COINS',
                      value: '$totalPoints',
                      imageAsset: 'assets/images/coin.png',
                      borderColor: const Color(0xFFF59E0B),
                      bgColor: const Color(0xFFFFFBEB),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'TOTAL IQ',
                      value: '$totalIQ',
                      imageAsset: 'assets/images/IQ.png',
                      borderColor: kMathBlue,
                      bgColor: const Color(0xffe0f7ff),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'AMAZING',
                      value: '$accuracy%',
                      icon: '✅',
                      borderColor: kGreen,
                      bgColor: kGreenLight,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── CTA button ────────────────────────────────────────
              GestureDetector(
                onTap: onButton,
                child: Stack(
                  children: [
                    Container(
                      height: 60 + 6,
                      decoration: BoxDecoration(
                        color: kPurpleShadow,
                        borderRadius: BorderRadius.circular(kRadiusLg),
                      ),
                    ),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPurpleMid, kPurple],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(kRadiusLg),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        buttonLabel,
                        style: const TextStyle(
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QuizCompletePage  — "Master Buster"
// ─────────────────────────────────────────────────────────────────────────────
class QuizCompletePage extends StatelessWidget {
  final String subjectName;
  final Color subjectColor;
  final int totalPoints;
  final int totalIQ;
  final int accuracy;

  const QuizCompletePage({
    super.key,
    required this.subjectName,
    required this.subjectColor,
    required this.totalPoints,
    required this.totalIQ,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return _CelebrationBase(
      title: 'Master Buster',
      subtitle: 'You done a very good job. keep doing.',
      totalPoints: totalPoints,
      totalIQ: totalIQ,
      accuracy: accuracy,
      buttonLabel: 'CLAIM IQ',
      onButton: () => Navigator.pop(context),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared stat card
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? icon;
  final String? imageAsset;
  final Color borderColor;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.icon,
    this.imageAsset,
    required this.borderColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: borderColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          if (imageAsset != null)
            Image.asset(
              imageAsset!,
              height: 22,
              width: 22,
              fit: BoxFit.contain,
            )
          else
            Text(icon ?? '⭐', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: borderColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small sparkle asterisk decoration
// ─────────────────────────────────────────────────────────────────────────────
class _Sparkle extends StatelessWidget {
  final Color color;
  final double size;

  const _Sparkle({required this.color, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Text(
      '✦',
      style: TextStyle(color: color, fontSize: size),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page indicator dot
// ─────────────────────────────────────────────────────────────────────────────
class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? kPurple : kBorderGrey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
