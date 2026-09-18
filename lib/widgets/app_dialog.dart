import 'package:flutter/material.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Standard confirmation/informational dialog. Use [AppDialog.show] rather
/// than calling `showDialog` with a bespoke widget so every dialog shares
/// the same spacing, typography, and button layout.
class AppDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    bool showCancel = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final textColor = Theme.of(ctx).colorScheme.onSurface;
        return AlertDialog(
          title: Text(title, style: AppTextStyles.titleLarge(textColor)),
          content: Text(message, style: AppTextStyles.bodyMedium(textColor)),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppDimens.space16,
            0,
            AppDimens.space16,
            AppDimens.space16,
          ),
          actions: [
            if (showCancel)
              Expanded(
                child: AppButton(
                  label: cancelLabel,
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.small,
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
              ),
            if (showCancel) const SizedBox(width: AppDimens.space12),
            Expanded(
              child: AppButton(
                label: confirmLabel,
                variant: isDestructive ? AppButtonVariant.destructive : AppButtonVariant.primary,
                size: AppButtonSize.small,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ),
          ],
        );
      },
    );
  }
}
