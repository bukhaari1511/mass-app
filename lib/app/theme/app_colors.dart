import 'package:flutter/material.dart';

/// Centralized application color palette.
/// Follows Material 3 design spec with an industrial dark charcoal & energetic orange brand theme.
class AppColors {
  // Primary Orange Brand Colors
  static const Color primary = Color(0xFFE65100);
  static const Color primaryVariant = Color(0xFFEF6C00);
  static const Color primaryLight = Color(0xFFFF9800);
  static const Color primaryContainer = Color(0xFFFFDCC8);
  static const Color onPrimaryContainer = Color(0xFF341100);

  // Secondary & Accents
  static const Color secondary = Color(0xFF37474F); // Dark slate neutral
  static const Color secondaryContainer = Color(0xFFECEFF1);
  static const Color onSecondaryContainer = Color(0xFF102027);

  // Neutral Backgrounds & Surfaces
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color border = Color(0xFFE2E8F0);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121316);
  static const Color darkSurface = Color(0xFF1C1E22);
  static const Color darkSurfaceVariant = Color(0xFF282C34);
  static const Color darkBorder = Color(0xFF383E48);

  // Status & Utility Colors
  static const Color offlineGreen = Color(0xFF2E7D32);
  static const Color offlineGreenBackground = Color(0xFFE8F5E9);
  
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textMuted = Color(0xFF9AA0A6);

  static const Color darkTextPrimary = Color(0xFFF1F3F5);
  static const Color darkTextSecondary = Color(0xFF9AA0A6);

  // Card & Elevation Shadows
  static const Color shadow = Color(0x0F000000);
}
