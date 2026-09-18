import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../shared/layouts/app_shell.dart';
import '../../shared/widgets/role_dashboard_widgets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'registration_controller.dart';
import 'registration_detail_screen.dart';
import 'registration_model.dart';

class RegistrationListScreen extends StatefulWidget {
  final String role;
  final bool embedded;

  const RegistrationListScreen({
    super.key,
    required this.role,
    this.embedded = false,
  });

  @override
  State<RegistrationListScreen> createState() => _RegistrationListScreenState();
}

class _RegistrationListScreenState extends State<RegistrationListScreen> {
  late final RegistrationController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<RegistrationController>()
        ? Get.find<RegistrationController>()
        : Get.put(RegistrationController());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildContent();
    }

    return AppShell(
      roleLabel: widget.role,
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
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(
            eyebrow: 'Participation',
            title: 'My registrations',
            subtitle:
                'Keep track of the events you have joined and their current registration status.',
          ),
          const SizedBox(
            height: AppDimens.space24,
          ),
          Expanded(
            child: controller.registrations.isEmpty
                ? const DashboardEmptyCard(
                    icon: Icons.event_note_outlined,
                    title: 'No registrations yet',
                    description:
                        'When you register for an event, it will appear here.',
                  )
                : RefreshIndicator(
                    color: AppColors.secondary,
                    onRefresh: controller.refresh,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                        bottom: 30,
                      ),
                      itemCount: controller.registrations.length,
                      separatorBuilder: (_, __) => const SizedBox(
                        height: 12,
                      ),
                      itemBuilder: (_, index) {
                        final item = controller.registrations[index];

                        return _RegistrationCard(
                          registration: item,
                          onTap: () {
                            Get.to(
                              () => RegistrationDetailScreen(
                                registration: item,
                                controller: controller,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RegistrationCard extends StatelessWidget {
  final RegistrationModel registration;
  final VoidCallback onTap;

  const _RegistrationCard({
    required this.registration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(
      registration.status,
    );

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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.event_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      registration.eventTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium(
                        AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      DateFormat(
                        'dd MMM yyyy • hh:mm a',
                      ).format(
                        registration.eventStartAt,
                      ),
                      style: AppTextStyles.bodySmall(
                        AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.11,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimens.radiusFull,
                  ),
                ),
                child: Text(
                  registration.statusLabel,
                  style: AppTextStyles.labelSmall(
                    color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
