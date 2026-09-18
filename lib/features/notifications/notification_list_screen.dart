import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'notification_controller.dart';
import 'notification_model.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({
    super.key,
  });

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late final NotificationController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(
            NotificationController(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Notifications',
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed:
                  controller.unreadCount > 0 ? controller.markAllRead : null,
              child: const Text(
                'Mark all read',
              ),
            ),
          ),
        ],
      ),
      body: Obx(
        () => controller.notifications.isEmpty
            ? const Center(
                child: Text(
                  'No notifications',
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(
                  16,
                ),
                itemCount: controller.notifications.length,
                separatorBuilder: (_, __) => const SizedBox(
                  height: 10,
                ),
                itemBuilder: (_, index) {
                  final item = controller.notifications[index];

                  return _NotificationCard(
                    notification: item,
                    onTap: () {
                      controller.markRead(
                        item.id,
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final icon = _icon(
      notification.type,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          18,
        ),
        child: Ink(
          padding: const EdgeInsets.all(
            17,
          ),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.darkSurface
                : AppColors.primary.withValues(
                    alpha: 0.08,
                  ),
            borderRadius: BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.darkBorder
                  : AppColors.primary.withValues(
                      alpha: 0.22,
                    ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.11,
                  ),
                  borderRadius: BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.titleMedium(
                              AppColors.darkTextPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      notification.message,
                      style: AppTextStyles.bodySmall(
                        AppColors.darkTextSecondary,
                      ),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      DateFormat(
                        'dd MMM • hh:mm a',
                      ).format(
                        notification.createdAt,
                      ),
                      style: AppTextStyles.labelSmall(
                        AppColors.darkTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(
    NotificationType type,
  ) {
    switch (type) {
      case NotificationType.announcement:
        return Icons.campaign_rounded;
      case NotificationType.event:
        return Icons.event_rounded;
      case NotificationType.attendance:
        return Icons.fact_check_rounded;
      case NotificationType.certificate:
        return Icons.workspace_premium_rounded;
      case NotificationType.system:
        return Icons.settings_rounded;
      case NotificationType.success:
        return Icons.check_circle_rounded;
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.error:
        return Icons.error_rounded;
      case NotificationType.info:
        return Icons.info_rounded;
    }
  }
}
