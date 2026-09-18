import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';

class DashboardHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const DashboardHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: AppTextStyles.labelSmall(
                  AppColors.secondary,
                ).copyWith(
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTextStyles.displayMedium(
                  AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 7),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 760,
                ),
                child: Text(
                  subtitle,
                  style: AppTextStyles.bodyLarge(
                    AppColors.darkTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppDimens.space20),
          trailing!,
        ],
      ],
    );
  }
}

class DashboardMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String supportingText;
  final IconData icon;
  final Color accentColor;

  const DashboardMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.supportingText,
    required this.icon,
    this.accentColor = AppColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimens.space20,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(
          AppDimens.radiusLarge,
        ),
        border: Border.all(
          color: AppColors.darkBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(
                    alpha: 0.11,
                  ),
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.north_east_rounded,
                color: AppColors.darkTextTertiary,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space20),
          Text(
            value,
            style: AppTextStyles.headlineLarge(
              AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: AppTextStyles.labelLarge(
              AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            supportingText,
            style: AppTextStyles.bodySmall(
              AppColors.darkTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimens.radiusLarge,
        ),
        child: Ink(
          padding: const EdgeInsets.all(
            AppDimens.space18,
          ),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(
              AppDimens.radiusLarge,
            ),
            border: Border.all(
              color: AppColors.darkBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.logoGradient,
                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium(
                        AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall(
                        AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: AppColors.darkTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.headlineMedium(
                  AppColors.darkTextPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall(
                    AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text(
              'View all',
            ),
          ),
      ],
    );
  }
}

class DashboardEmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DashboardEmptyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimens.space32,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(
          AppDimens.radiusXLarge,
        ),
        border: Border.all(
          color: AppColors.darkBorder,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(
                18,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.secondary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.titleLarge(
              AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(
                AppColors.darkTextSecondary,
              ),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
