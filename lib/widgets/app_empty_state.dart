import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';

/// Empty-list / no-results placeholder used across every feature module's
/// list screens (no events yet, no certificates yet, no announcements, ...).
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.lightTextSecondary),
            const SizedBox(height: AppDimens.space16),
            Text(title, style: AppTextStyles.titleMedium(textColor), textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimens.space8),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall(AppColors.lightTextSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimens.space20),
              SizedBox(
                width: 180,
                child: AppButton(label: actionLabel!, size: AppButtonSize.small, onPressed: onAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
