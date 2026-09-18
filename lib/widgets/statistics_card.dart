import 'package:flutter/material.dart';
import 'app_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Compact metric card used on dashboards (e.g. "Events Attended: 12",
/// "Certificates: 4", "Rank: #7"). Supports an optional trend indicator.
class StatisticsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;
  final String? trendLabel;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const StatisticsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
    this.trendLabel,
    this.isPositiveTrend = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = Theme.of(context).textTheme.bodyLarge?.color;
    final color = accentColor ?? AppColors.primary;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.space8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                ),
                child: Icon(icon, color: color, size: AppDimens.iconMedium),
              ),
              if (trendLabel != null)
                Row(
                  children: [
                    Icon(
                      isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                      size: AppDimens.iconSmall,
                      color: isPositiveTrend ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trendLabel!,
                      style: AppTextStyles.bodySmall(
                        isPositiveTrend ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          Text(value, style: AppTextStyles.headlineLarge(textPrimary ?? AppColors.lightTextPrimary)),
          const SizedBox(height: AppDimens.space4),
          Text(label, style: AppTextStyles.bodySmall(AppColors.lightTextSecondary)),
        ],
      ),
    );
  }
}
