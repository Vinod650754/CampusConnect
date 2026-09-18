import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Central snackbar helper. Use these instead of calling
/// `ScaffoldMessenger` directly so toasts stay visually consistent and can
/// be triggered from GetX controllers without a `BuildContext`.
class AppSnackbar {
  static void success(String message, {String title = 'Success'}) {
    _show(title: title, message: message, color: AppColors.success, icon: Icons.check_circle_outline);
  }

  static void error(String message, {String title = 'Error'}) {
    _show(title: title, message: message, color: AppColors.error, icon: Icons.error_outline);
  }

  static void info(String message, {String title = 'Info'}) {
    _show(title: title, message: message, color: AppColors.info, icon: Icons.info_outline);
  }

  static void warning(String message, {String title = 'Warning'}) {
    _show(title: title, message: message, color: AppColors.warning, icon: Icons.warning_amber_outlined);
  }

  static void _show({
    required String title,
    required String message,
    required Color color,
    required IconData icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      titleText: Text(title, style: AppTextStyles.titleMedium(Colors.white)),
      messageText: Text(message, style: AppTextStyles.bodyMedium(Colors.white)),
      duration: const Duration(seconds: 3),
    );
  }
}
