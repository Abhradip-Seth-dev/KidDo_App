import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff7C3AED), // Primary purple from PRD
        primary: const Color(0xff7C3AED),
        secondary: const Color(0xffF59E0B), // Accent yellow/gold from PRD
        background: const Color(0xfff5f5f5),
      ),
      textTheme: GoogleFonts.nunitoTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
