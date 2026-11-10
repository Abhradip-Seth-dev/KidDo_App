import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// KidDO Design System — Centralised colour & style tokens
// ─────────────────────────────────────────────────────────────────────────────

// ── Brand purple ──────────────────────────────────────────────────────────────
const Color kPurple       = Color(0xff7c3aed);
const Color kPurpleMid    = Color(0xff8b5cf6);
const Color kPurpleLight  = Color(0xffede9fe);
const Color kPurpleShadow = Color(0xff5b21b6);

// ── Subject colours ───────────────────────────────────────────────────────────
const Color kMathBlue         = Color(0xff38bdf8);
const Color kMathBlueLight    = Color(0xffe0f7ff);
const Color kGKGreen          = Color(0xff22c55e);
const Color kGKGreenLight     = Color(0xffdcfce7);
const Color kSciencePink      = Color(0xfffda4af);
const Color kSciencePinkLight = Color(0xfffff1f2);
const Color kEnglishPurple    = Color(0xffa78bfa);
const Color kEnglishPurpleLight = Color(0xfff3f0ff);
const Color kComputerYellow   = Color(0xfffbbf24);
const Color kComputerYellowLight = Color(0xfffef9c3);

// ── Gamification / economy ─────────────────────────────────────────────────
const Color kGold       = Color(0xfff59e0b);  // coins / IQ badge
const Color kGoldLight  = Color(0xfffef3c7);
const Color kOrange     = Color(0xffff7300);  // streak
const Color kOrangeLight = Color(0xfffff8de);

// ── Feedback ──────────────────────────────────────────────────────────────────
const Color kGreen      = Color(0xff16a34a);  // correct
const Color kGreenLight = Color(0xffdcfce7);
const Color kRed        = Color(0xffef4444);  // incorrect / logout
const Color kRedLight   = Color(0xfffee2e2);

// ── Neutral scaffold / text ───────────────────────────────────────────────────
const Color kScaffoldBg = Color(0xffF9F9F9);
const Color kCardWhite  = Colors.white;
const Color kTextDark   = Color(0xff1e1e2c);
const Color kTextGrey   = Color(0xff9ca3af);
const Color kBorderGrey = Color(0xffe5e7eb);

// ── Shared border radius ──────────────────────────────────────────────────────
const double kRadiusSm  = 12;
const double kRadiusMd  = 20;
const double kRadiusLg  = 30;
const double kRadiusXl  = 40;

// ── Subject metadata helper ───────────────────────────────────────────────────
class SubjectTheme {
  final String name;
  final Color primary;
  final Color light;
  final String imageAsset;

  const SubjectTheme({
    required this.name,
    required this.primary,
    required this.light,
    required this.imageAsset,
  });
}

const Map<String, SubjectTheme> kSubjectThemes = {
  'Math': SubjectTheme(
    name: 'Math',
    primary: kMathBlue,
    light: kMathBlueLight,
    imageAsset: 'assets/images/Math.png',
  ),
  'GK': SubjectTheme(
    name: 'GK',
    primary: kGKGreen,
    light: kGKGreenLight,
    imageAsset: 'assets/images/GK.png',
  ),
  'Science': SubjectTheme(
    name: 'Science',
    primary: kSciencePink,
    light: kSciencePinkLight,
    imageAsset: 'assets/images/Science.png',
  ),
  'English': SubjectTheme(
    name: 'English',
    primary: kEnglishPurple,
    light: kEnglishPurpleLight,
    imageAsset: 'assets/images/English.png',
  ),
  'Computer': SubjectTheme(
    name: 'Computer',
    primary: kComputerYellow,
    light: kComputerYellowLight,
    imageAsset: 'assets/images/Computer.png',
  ),
};
