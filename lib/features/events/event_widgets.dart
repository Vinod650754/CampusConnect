import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'event_model.dart';

class EventStatusChip extends StatelessWidget {
  final EventStatus status;

  const EventStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;

    switch (status) {
      case EventStatus.upcoming:
        color = AppColors.info;
        break;
      case EventStatus.ongoing:
        color = AppColors.success;
        break;
      case EventStatus.completed:
        color = AppColors.darkTextTertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.11,
        ),
        borderRadius: BorderRadius.circular(
          AppDimens.radiusFull,
        ),
        border: Border.all(
          color: color.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: AppTextStyles.labelSmall(
          color,
        ).copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _AttendanceChip extends StatelessWidget {
  final String label;
  const _AttendanceChip({required this.label});
  @override
  Widget build(BuildContext context) {
    final present = label == 'Present' || label == 'Attended';
    final color = present ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(label.toUpperCase(), style: AppTextStyles.labelSmall(color)),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final VoidCallback? onPrimaryAction;
  final String primaryActionLabel;
  final bool showPrimaryAction;
  final String? ownAttendanceLabel;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onPrimaryAction,
    this.primaryActionLabel = 'View',
    this.showPrimaryAction = true,
    this.ownAttendanceLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimens.radiusXLarge,
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(
              AppDimens.radiusXLarge,
            ),
            border: Border.all(
              color: AppColors.darkBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimens.space16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBanner(context),
                const SizedBox(
                  height: AppDimens.space16,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleLarge(
                          AppColors.darkTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    EventStatusChip(
                      status: event.status,
                    ),
                    if (ownAttendanceLabel != null && ownAttendanceLabel != 'Not marked') ...[
                      const SizedBox(width: 6),
                      _AttendanceChip(label: ownAttendanceLabel!),
                    ],
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  event.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall(
                    AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                _infoRow(
                  Icons.schedule_rounded,
                  _dateText(),
                ),
                const SizedBox(
                  height: 8,
                ),
                _infoRow(
                  event.isOnline
                      ? Icons.videocam_outlined
                      : Icons.location_on_outlined,
                  event.isOnline
                      ? 'Online event'
                      : event.venue ?? 'Venue to be announced',
                ),
                const SizedBox(
                  height: 14,
                ),
                Row(
                  children: [
                    _miniStat(
                      Icons.people_outline_rounded,
                      '${event.registrationCount}',
                      'registered',
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    _miniStat(
                      Icons.fact_check_outlined,
                      '${event.attendanceCount}',
                      'attended',
                    ),
                    const Spacer(),
                    if (showPrimaryAction)
                      FilledButton(
                        onPressed: onPrimaryAction,
                        child: Text(
                          primaryActionLabel,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(
    BuildContext context,
  ) {
    if (event.bannerUrl == null) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(
            18,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -35,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.08,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 18,
              child: Text(
                DateFormat('EEE • dd MMM')
                    .format(
                      event.startAt,
                    )
                    .toUpperCase(),
                style: AppTextStyles.labelLarge(
                  Colors.white,
                ).copyWith(
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        18,
      ),
      child: Image.network(
        event.bannerUrl!,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            height: 150,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: AppColors.secondary,
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall(
              AppColors.darkTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniStat(
    IconData icon,
    String value,
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: AppColors.darkTextTertiary,
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          value,
          style: AppTextStyles.labelSmall(
            AppColors.darkTextPrimary,
          ),
        ),
        const SizedBox(
          width: 3,
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall(
            AppColors.darkTextTertiary,
          ),
        ),
      ],
    );
  }

  String _dateText() {
    return '${DateFormat('EEE, dd MMM • hh:mm a').format(event.startAt)}'
        ' — '
        '${DateFormat('hh:mm a').format(event.endAt)}';
  }
}

class EventFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const EventFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimens.radiusFull,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(
                    alpha: 0.17,
                  )
                : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(
              AppDimens.radiusFull,
            ),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.darkBorder,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelLarge(
              selected ? AppColors.secondary : AppColors.darkTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
