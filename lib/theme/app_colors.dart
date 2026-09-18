import 'package:flutter/material.dart';

/// Campus Connect design system.
///
/// Keep all application colors here so existing widgets, theme,
/// splash screen and feature screens share one visual language.
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // BRAND
  // ═══════════════════════════════════════════════════════════════

  /// Primary Campus Connect purple/indigo.
  static const Color primary = Color(0xFF6366F1);

  /// Secondary brand cyan/teal.
  ///
  /// Kept as `secondary` because the existing theme, splash screen
  /// and reusable widgets already depend on this name.
  static const Color secondary = Color(0xFF22D3EE);

  /// Accent purple used for highlights and brand details.
  static const Color accent = Color(0xFFA855F7);

  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  static const Color cyan = Color(0xFF22D3EE);
  static const Color cyanDark = Color(0xFF06B6D4);

  static const Color purple = Color(0xFFA855F7);
  static const Color purpleDark = Color(0xFF7C3AED);

  // ═══════════════════════════════════════════════════════════════
  // DARK BACKGROUND
  // ═══════════════════════════════════════════════════════════════

  static const Color darkBackground = Color(0xFF050507);

  static const Color darkSurface = Color(0xFF0B0B10);

  static const Color darkSurfaceElevated = Color(0xFF111119);

  static const Color darkSurfaceBright = Color(0xFF161620);

  // ═══════════════════════════════════════════════════════════════
  // BORDERS
  // ═══════════════════════════════════════════════════════════════

  static const Color darkBorder = Color(0xFF24242E);

  static const Color darkBorderBright = Color(0xFF353544);

  // ═══════════════════════════════════════════════════════════════
  // DARK TEXT
  // ═══════════════════════════════════════════════════════════════

  static const Color darkTextPrimary = Color(0xFFF7F7FA);

  static const Color darkTextSecondary = Color(0xFF9A9AA8);

  /// Existing project widgets use this name.
  static const Color darkTextTertiary = Color(0xFF666675);

  /// Alias used for very low-emphasis text.
  static const Color darkTextMuted = Color(0xFF666675);

  // ═══════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════

  static const Color lightBackground = Color(0xFFFFFFFF);

  static const Color lightSurface = Color(0xFFF7F7F9);

  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);

  static const Color lightBorder = Color(0xFFE5E7EB);

  static const Color lightBorderBright = Color(0xFFD1D5DB);

  static const Color lightTextPrimary = Color(0xFF11121A);

  static const Color lightTextSecondary = Color(0xFF6B7280);

  static const Color lightTextTertiary = Color(0xFF9CA3AF);

  // ═══════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF34D399);

  static const Color warning = Color(0xFFFBBF24);

  static const Color error = Color(0xFFFB7185);

  static const Color info = Color(0xFF38BDF8);

  // ═══════════════════════════════════════════════════════════════
  // BRAND GRADIENTS
  // ═══════════════════════════════════════════════════════════════

  /// Main Campus Connect gradient.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF7C3AED),
      Color(0xFF6366F1),
      Color(0xFF22D3EE),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Gradient specifically for the Campus Connect logo.
  static const LinearGradient logoGradient = LinearGradient(
    colors: [
      Color(0xFFA855F7),
      Color(0xFF6366F1),
      Color(0xFF22D3EE),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle dark background gradient.
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF050507),
      Color(0xFF080810),
      Color(0xFF050507),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ═══════════════════════════════════════════════════════════════
  // HELPER COLORS
  // ═══════════════════════════════════════════════════════════════

  static Color primaryWithOpacity(double opacity) {
    return primary.withValues(alpha: opacity);
  }

  static Color secondaryWithOpacity(double opacity) {
    return secondary.withValues(alpha: opacity);
  }

  static Color accentWithOpacity(double opacity) {
    return accent.withValues(alpha: opacity);
  }

  static Color textPrimaryWithOpacity(double opacity) {
    return darkTextPrimary.withValues(alpha: opacity);
  }

  static Color textSecondaryWithOpacity(double opacity) {
    return darkTextSecondary.withValues(alpha: opacity);
  }
}
