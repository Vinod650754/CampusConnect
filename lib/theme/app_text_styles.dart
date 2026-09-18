import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography scale. Uses Inter (a Linear/Notion-esque grotesque) for the
/// whole app. Centralizing this means a font swap is a one-line change.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Light-mode variants
  static TextStyle displayLarge(Color c) => _base(size: 40, weight: FontWeight.w700, color: c, letterSpacing: -0.5);
  static TextStyle displayMedium(Color c) => _base(size: 32, weight: FontWeight.w700, color: c, letterSpacing: -0.5);
  static TextStyle displaySmall(Color c) => _base(size: 28, weight: FontWeight.w700, color: c, letterSpacing: -0.4);
  static TextStyle headlineLarge(Color c) => _base(size: 26, weight: FontWeight.w600, color: c);
  static TextStyle headlineMedium(Color c) => _base(size: 22, weight: FontWeight.w600, color: c);
  static TextStyle titleLarge(Color c) => _base(size: 18, weight: FontWeight.w600, color: c);
  static TextStyle titleMedium(Color c) => _base(size: 16, weight: FontWeight.w600, color: c);
  static TextStyle bodyLarge(Color c) => _base(size: 16, weight: FontWeight.w400, color: c, height: 1.5);
  static TextStyle bodyMedium(Color c) => _base(size: 14, weight: FontWeight.w400, color: c, height: 1.5);
  static TextStyle bodySmall(Color c) => _base(size: 12, weight: FontWeight.w400, color: c, height: 1.4);
  static TextStyle labelLarge(Color c) => _base(size: 14, weight: FontWeight.w600, color: c);
  static TextStyle labelSmall(Color c) => _base(size: 11, weight: FontWeight.w500, color: c, letterSpacing: 0.4);

  // Convenience presets bound to default light/dark primary text colors
  static final light = _Preset(AppColors.lightTextPrimary, AppColors.lightTextSecondary);
  static final dark = _Preset(AppColors.darkTextPrimary, AppColors.darkTextSecondary);
}

class _Preset {
  final Color primary;
  final Color secondary;
  _Preset(this.primary, this.secondary);

  TextStyle get displayLarge => AppTextStyles.displayLarge(primary);
  TextStyle get displaySmall => AppTextStyles.displaySmall(primary);
  TextStyle get headlineMedium => AppTextStyles.headlineMedium(primary);
  TextStyle get titleMedium => AppTextStyles.titleMedium(primary);
  TextStyle get bodyMedium => AppTextStyles.bodyMedium(primary);
  TextStyle get bodySmall => AppTextStyles.bodySmall(secondary);
}
