// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

/// Central color tokens for DigiVir app.
/// All UI components reference these — no ad-hoc color values anywhere.
class AppColors {
  AppColors._();

  // Brand palette
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color primaryLight = Color(0xFFD2E3FC);
  static const Color accent = Color(0xFF34A853);
  static const Color accentLight = Color(0xFFE6F4EA);

  // Surface
  static const Color background = Color(0xFFF8FAFE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5FF);
  static const Color cardBorder = Color(0xFFE3EAF6);

  // Text
  static const Color textPrimary = Color(0xFF1C2B4A);
  static const Color textSecondary = Color(0xFF5F6B84);
  static const Color textHint = Color(0xFFADB5C7);

  // Status
  static const Color success = Color(0xFF1E8A4C);
  static const Color successLight = Color(0xFFEAF6EE);
  static const Color error = Color(0xFFD93025);
  static const Color errorLight = Color(0xFFFCE8E6);
  static const Color warning = Color(0xFFF9AB00);
  static const Color warningLight = Color(0xFFFEF3CD);

  // Friction logger
  static const Color frictionBg = Color(0xFFFFF8E1);
  static const Color frictionBorder = Color(0xFFFFCC02);
  static const Color frictionText = Color(0xFF856404);

  // Input
  static const Color inputBorder = Color(0xFFCDD4E7);
  static const Color inputFocusBorder = Color(0xFF1A73E8);
  static const Color inputFillColor = Color(0xFFF6F9FF);
}
