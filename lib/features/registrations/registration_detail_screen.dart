import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../shared/layouts/app_shell.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'registration_controller.dart';
import 'registration_model.dart';

class RegistrationDetailScreen extends StatelessWidget {
  final RegistrationModel registration;
  final RegistrationController controller;

  const RegistrationDetailScreen({
    super.key,
    required this.registration,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AppShell(
      roleLabel: 'PARTICIPANT',
      destinations: const [
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
      ],
      selectedIndex: 1,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final active = registration.status != RegistrationStatus.cancelled;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REGISTRATION',
            style: AppTextStyles.labelSmall(
              AppColors.secondary,
            ).copyWith(
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            registration.eventTitle,
            style: AppTextStyles.displayMedium(
              AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Registered on ${DateFormat('dd MMM yyyy, hh:mm a').format(registration.registeredAt)}',
            style: AppTextStyles.bodyMedium(
              AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(
            height: AppDimens.space24,
          ),
          _statusCard(),
          const SizedBox(
            height: AppDimens.space16,
          ),
          _detailPanel(),
          const SizedBox(
            height: AppDimens.space16,
          ),
          if (active &&
              registration.eventStartAt.isAfter(
                DateTime.now(),
              ))
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _cancel,
                icon: const Icon(
                  Icons.cancel_outlined,
                ),
                label: const Text(
                  'Cancel registration',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusCard() {
    final color = _statusColor(
      registration.status,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(
          AppDimens.radiusXLarge,
        ),
        border: Border.all(
          color: color.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(
                15,
              ),
            ),
            child: Icon(
              _statusIcon(
                registration.status,
              ),
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registration.statusLabel,
                  style: AppTextStyles.headlineMedium(
                    color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusDescription(
                    registration.status,
                  ),
                  style: AppTextStyles.bodySmall(
                    AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
          _row(
            Icons.event_rounded,
            'Start',
            DateFormat(
              'dd MMM yyyy • hh:mm a',
            ).format(
              registration.eventStartAt,
            ),
          ),
          const Divider(
            color: AppColors.darkBorder,
            height: 26,
          ),
          _row(
            Icons.event_available_rounded,
            'End',
            DateFormat(
              'dd MMM yyyy • hh:mm a',
            ).format(
              registration.eventEndAt,
            ),
          ),
          const Divider(
            color: AppColors.darkBorder,
            height: 26,
          ),
          _row(
            Icons.person_outline_rounded,
            'Participant',
            registration.userName,
          ),
          const Divider(
            color: AppColors.darkBorder,
            height: 26,
          ),
          _row(
            Icons.email_outlined,
            'Email',
            registration.userEmail,
          ),
        ],
      ),
    );
  }

  Widget _row(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.secondary,
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
              const SizedBox(height: 3),
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

  void _cancel() {
    controller.cancelRegistration(
      registration.id,
    );

    Get.snackbar(
      'Registration cancelled',
      'Your event registration has been cancelled.',
      snackPosition: SnackPosition.BOTTOM,
    );

    Get.back();
  }

  Color _statusColor(
    RegistrationStatus status,
  ) {
    switch (status) {
      case RegistrationStatus.confirmed:
        return AppColors.success;
      case RegistrationStatus.attended:
        return AppColors.secondary;
      case RegistrationStatus.pending:
        return AppColors.warning;
      case RegistrationStatus.waitlisted:
        return AppColors.info;
      case RegistrationStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _statusIcon(
    RegistrationStatus status,
  ) {
    switch (status) {
      case RegistrationStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case RegistrationStatus.attended:
        return Icons.verified_rounded;
      case RegistrationStatus.pending:
        return Icons.schedule_rounded;
      case RegistrationStatus.waitlisted:
        return Icons.hourglass_empty_rounded;
      case RegistrationStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _statusDescription(
    RegistrationStatus status,
  ) {
    switch (status) {
      case RegistrationStatus.confirmed:
        return 'Your seat is confirmed for this event.';
      case RegistrationStatus.attended:
        return 'Your participation has been recorded.';
      case RegistrationStatus.pending:
        return 'Your registration is waiting for confirmation.';
      case RegistrationStatus.waitlisted:
        return 'You are currently on the event waitlist.';
      case RegistrationStatus.cancelled:
        return 'This registration is no longer active.';
    }
  }
}
