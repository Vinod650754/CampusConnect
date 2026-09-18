import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../shared/layouts/app_shell.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'attendance_qr_screen.dart';
import 'event_controller.dart';
import 'event_form_screen.dart';
import 'event_model.dart';
import '../registrations/registration_controller.dart';
import '../registrations/event_registration_management_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;
  final String role;
  final EventController controller;
  final bool embedded;

  const EventDetailScreen({
    super.key,
    required this.eventId,
    required this.role,
    required this.controller,
    this.embedded = false,
  });

  bool get canManageEvents => role == 'ADMIN' || role == 'SUPER_ADMIN' || role == 'CORE_TEAM';

  bool get canRegister => role == 'STUDENT' || role == 'MEMBER';

  @override
  Widget build(BuildContext context) {
    final event = controller.events.firstWhere(
      (item) => item.id == eventId,
      orElse: () => controller.events.first,
    );

    final content = _buildContent(
      context,
      event,
    );

    if (embedded) {
      return content;
    }

    return AppShell(
      roleLabel: role,
      destinations: _destinations(),
      selectedIndex: 1,
      onDestinationSelected: (_) {},
      child: content,
    );
  }

  List<AppShellDestination> _destinations() {
    return const [
      AppShellDestination(
        label: 'Dashboard',
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
      ),
      AppShellDestination(
        label: 'Events',
        icon: Icons.event_outlined,
        activeIcon: Icons.event_rounded,
      ),
      AppShellDestination(
        label: 'Attend',
        icon: Icons.qr_code_2_outlined,
        activeIcon: Icons.qr_code_2_rounded,
      ),
      AppShellDestination(
        label: 'Updates',
        icon: Icons.campaign_outlined,
        activeIcon: Icons.campaign_rounded,
      ),
    ];
  }

  Widget _buildContent(
    BuildContext context,
    EventModel event,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHero(
            context,
            event,
          ),
          const SizedBox(
            height: AppDimens.space20,
          ),
          LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              if (constraints.maxWidth < 950) {
                return Column(
                  children: [
                    _buildMainInfo(
                      context,
                      event,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildSidePanel(
                      context,
                      event,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: _buildMainInfo(
                      context,
                      event,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    flex: 4,
                    child: _buildSidePanel(
                      context,
                      event,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHero(
    BuildContext context,
    EventModel event,
  ) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 230,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppDimens.radiusXLarge,
        ),
        gradient: AppColors.primaryGradient,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -90,
            top: -80,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                EventStatusPill(
                  status: event.status,
                ),
                const SizedBox(
                  height: 14,
                ),
                Text(
                  event.title,
                  style: AppTextStyles.displayMedium(
                    Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  DateFormat(
                    'EEEE, dd MMMM yyyy • hh:mm a',
                  ).format(
                    event.startAt,
                  ),
                  style: AppTextStyles.bodyMedium(
                    Colors.white.withValues(
                      alpha: 0.82,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfo(
    BuildContext context,
    EventModel event,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About this event',
                style: AppTextStyles.headlineMedium(
                  AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                event.description,
                style: AppTextStyles.bodyLarge(
                  AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event details',
                style: AppTextStyles.headlineMedium(
                  AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              _detailRow(
                Icons.schedule_rounded,
                'Schedule',
                '${DateFormat('dd MMM yyyy, hh:mm a').format(event.startAt)}\n'
                    '${DateFormat('dd MMM yyyy, hh:mm a').format(event.endAt)}',
              ),
              const Divider(
                height: 28,
                color: AppColors.darkBorder,
              ),
              _detailRow(
                event.isOnline
                    ? Icons.videocam_outlined
                    : Icons.location_on_outlined,
                event.isOnline ? 'Event type' : 'Venue',
                event.isOnline ? 'Online' : event.venue ?? 'To be announced',
              ),
              const Divider(
                height: 28,
                color: AppColors.darkBorder,
              ),
              _detailRow(
                Icons.people_outline_rounded,
                'Registrations',
                event.capacity == null
                    ? '${event.registrationCount} registered'
                    : '${event.registrationCount} / ${event.capacity}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidePanel(
    BuildContext context,
    EventModel event,
  ) {
    return Column(
      children: [
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event actions',
                style: AppTextStyles.headlineMedium(
                  AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              if (canManageEvents) ...[
                _actionButton(
                  context,
                  icon: Icons.edit_outlined,
                  label: 'Edit event',
                  onTap: () {
                    Get.to(
                      () => EventFormScreen(
                        controller: controller,
                        role: role,
                        existingEvent: event,
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                _actionButton(
                  context,
                  icon: Icons.groups_rounded,
                  label: 'Participants',
                  onTap: () {
                    Get.to(() => EventRegistrationManagementScreen(
                      eventId: event.id,
                      eventTitle: event.title,
                      role: role,
                    ));
                  },
                ),
                const SizedBox(height: 10),
                _actionButton(
                  context,
                  icon: Icons.qr_code_2_rounded,
                  label: 'Attendance QR',
                  onTap: () {
                    Get.to(
                      () => AttendanceQrScreen(
                        event: event,
                        role: role,
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                _actionButton(
                  context,
                  icon: event.isPublished
                      ? Icons.visibility_outlined
                      : Icons.publish_outlined,
                  label: event.isPublished ? 'Published' : 'Publish event',
                  onTap: event.isPublished
                      ? null
                      : () {
                          controller.publishEvent(
                            event.id,
                          );
                        },
                ),
              ],
              if (canRegister &&
                  event.isPublished &&
                  event.status == EventStatus.upcoming)
                _actionButton(
                  context,
                  icon: Icons.how_to_reg_rounded,
                  label: 'Register for event',
                  onTap: () async {
                    final registrationController =
                        Get.isRegistered<RegistrationController>()
                            ? Get.find<RegistrationController>()
                            : Get.put(RegistrationController());

                    final success = await registrationController.registerForEvent(event.id);

                    if (success) {
                      await controller.loadEvent(event.id);
                      Get.snackbar(
                        'Registration successful',
                        'You are registered for ${event.title}.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } else {
                      Get.snackbar(
                        'Registration failed',
                        registrationController.errorMessage.value ?? 'Unable to register for this event.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                ),
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attendance',
                style: AppTextStyles.headlineMedium(
                  AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                '${event.attendanceCount} attendees recorded',
                style: AppTextStyles.bodyMedium(
                  AppColors.darkTextSecondary,
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              LinearProgressIndicator(
                value: event.registrationCount == 0
                    ? 0
                    : (event.attendanceCount / event.registrationCount).clamp(
                        0,
                        1,
                      ),
                minHeight: 7,
                borderRadius: BorderRadius.circular(
                  AppDimens.radiusFull,
                ),
                backgroundColor: AppColors.darkBorder,
                valueColor: const AlwaysStoppedAnimation(
                  AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _panel({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            icon,
            size: 19,
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
              Text(
                label,
                style: AppTextStyles.labelSmall(
                  AppColors.darkTextTertiary,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium(
                  AppColors.darkTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class EventStatusPill extends StatelessWidget {
  final EventStatus status;

  const EventStatusPill({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = status == EventStatus.ongoing
        ? AppColors.success
        : status == EventStatus.upcoming
            ? AppColors.info
            : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(
          AppDimens.radiusFull,
        ),
        border: Border.all(
          color: color.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: AppTextStyles.labelSmall(
          color,
        ).copyWith(
          letterSpacing: 1.0,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
