import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect/theme/app_theme.dart';
import 'package:campus_connect/theme/app_colors.dart';

void main() {
  group('Design system foundation', () {
    test('light and dark themes build without throwing', () {
      expect(AppTheme.light, isNotNull);
      expect(AppTheme.dark, isNotNull);
    });

    test('brand colors are defined', () {
      expect(AppColors.primary, isNotNull);
      expect(AppColors.secondary, isNotNull);
    });
  });
}
