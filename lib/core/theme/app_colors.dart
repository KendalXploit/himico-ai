import 'package:flutter/material.dart';

/// HIMICO AI — Cyberpunk Black/Blue Neon palette.
/// Single source of truth for every color used across the app.
abstract class AppColors {
  const AppColors._();

  // Base surfaces
  static const Color voidBlack = Color(0xFF03050A);
  static const Color background = Color(0xFF060A12);
  static const Color surface = Color(0xFF0B1220);
  static const Color surfaceElevated = Color(0xFF101A2C);
  static const Color surfaceGlass = Color(0x1A1E3A5F);
  static const Color border = Color(0xFF1C2B45);
  static const Color borderGlow = Color(0x662E9BFF);

  // Neon accents
  static const Color neonBlue = Color(0xFF2E9BFF);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonElectric = Color(0xFF3D5CFF);
  static const Color neonPurple = Color(0xFF8B5CF6);

  // Semantic (trading)
  static const Color bullish = Color(0xFF00F0A8);
  static const Color bullishDim = Color(0xFF0A3D31);
  static const Color bearish = Color(0xFFFF3B69);
  static const Color bearishDim = Color(0xFF3D0A1A);
  static const Color warning = Color(0xFFFFB020);
  static const Color noTrade = Color(0xFF5B6B8C);

  // Text
  static const Color textPrimary = Color(0xFFEAF2FF);
  static const Color textSecondary = Color(0xFF8FA2C7);
  static const Color textMuted = Color(0xFF566486);
  static const Color textOnNeon = Color(0xFF03050A);

  // Gradients
  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonElectric, neonCyan],
  );

  static const LinearGradient bullishGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00F0A8), Color(0xFF00B37D)],
  );

  static const LinearGradient bearishGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF3B69), Color(0xFFC2185B)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF060A12), Color(0xFF03050A)],
  );

  static const RadialGradient glowRadial = RadialGradient(
    colors: [Color(0x552E9BFF), Color(0x00000000)],
    radius: 0.85,
  );

  static Color confidence(double value) {
    if (value >= 90) return bullish;
    if (value >= 70) return neonCyan;
    if (value >= 50) return warning;
    return noTrade;
  }
}
