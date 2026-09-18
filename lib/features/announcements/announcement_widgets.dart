import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'announcement_model.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool canManage;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.canManage = false,
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
              color: announcement.isPinned
                  ? AppColors.secondary.withValues(
                      alpha: 0.35,
                    )
                  : AppColors.darkBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(
                        13,
                      ),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium(
                            AppColors.darkTextPrimary,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          announcement.authorName,
                          style: AppTextStyles.labelSmall(
                            AppColors.darkTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (announcement.isPinned)
                    const Icon(
                      Icons.push_pin_rounded,
                      color: AppColors.secondary,
                      size: 18,
                    ),
                  if (canManage)
                    PopupMenuButton<String>(
                      color: AppColors.darkSurfaceElevated,
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        }

                        if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              Text(
                announcement.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium(
                  AppColors.darkTextSecondary,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _tag(announcement.audienceLabel),
                  if (announcement.publishedAt != null)
                    Text(
                      DateFormat('dd MMM • hh:mm a').format(
                        announcement.publishedAt!,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall(
                        AppColors.darkTextTertiary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(
          AppDimens.radiusFull,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall(
          AppColors.secondary,
        ),
      ),
    );
  }
}
