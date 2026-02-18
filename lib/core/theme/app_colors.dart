import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark theme backgrounds
  static const Color background = Color(0xFF1A1D2E);
  static const Color surface = Color(0xFF252A3D);

  // Primary accent colors
  static const Color primary = Color(0xFF4A90E2);
  static const Color primaryDark = Color(0xFF357ABD);

  // Glass / overlay colors
  static const Color glassFill = Color(0x0DFFFFFF); // white 5%
  static const Color glassBorder = Color(0x1AFFFFFF); // white 10%
  static const Color glassHighlight = Color(0x26FFFFFF); // white 15%

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0x99FFFFFF); // white 60%
  static const Color textHint = Color(0x66FFFFFF); // white 40%
  static const Color textDisabled = Color(0x4DFFFFFF); // white 30%

  // Semantic colors
  static const Color error = Colors.red;
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // Gradient presets
  static const List<Color> primaryGradient = [primary, primaryDark];
  static const List<Color> backgroundGradient = [
    background,
    surface,
    background,
  ];
}
