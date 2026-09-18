import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, text, destructive }
enum AppButtonSize { small, medium, large }

/// The single button component used across the entire app. Do not create
/// ad-hoc `ElevatedButton`/`TextButton` instances in feature code — extend
/// this widget instead so every button stays visually consistent.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  double get _height => switch (size) {
        AppButtonSize.small => 40,
        AppButtonSize.medium => AppDimens.buttonHeight,
        AppButtonSize.large => 60,
      };

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation(_foregroundColor(context)),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppDimens.iconSmall, color: _foregroundColor(context)),
                const SizedBox(width: AppDimens.space8),
              ],
              Text(label, style: AppTextStyles.labelLarge(_foregroundColor(context))),
            ],
          );

    final button = _buildByVariant(context, child);

    return SizedBox(
      height: _height,
      width: isFullWidth ? double.infinity : null,
      child: button,
    );
  }

  Widget _buildByVariant(BuildContext context, Widget child) {
    final radius = BorderRadius.circular(AppDimens.radiusMedium);

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: radius),
            elevation: 0,
          ),
          child: child,
        );
      case AppButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            shape: RoundedRectangleBorder(borderRadius: radius),
            elevation: 0,
          ),
          child: child,
        );
      case AppButtonVariant.destructive:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            shape: RoundedRectangleBorder(borderRadius: radius),
            elevation: 0,
          ),
          child: child,
        );
      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: radius)),
          child: child,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: radius)),
          child: child,
        );
    }
  }

  Color _foregroundColor(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.destructive:
        return Colors.white;
      case AppButtonVariant.outline:
      case AppButtonVariant.text:
        return Theme.of(context).colorScheme.onSurface;
    }
  }
}
