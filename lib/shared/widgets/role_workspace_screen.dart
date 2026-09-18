import 'package:flutter/material.dart';

import '../layouts/app_shell.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';

class RoleWorkspaceScreen extends StatefulWidget {
  final String role;
  final String title;
  final String subtitle;

  const RoleWorkspaceScreen({
    super.key,
    required this.role,
    required this.title,
    required this.subtitle,
  });

  @override
  State<RoleWorkspaceScreen> createState() => _RoleWorkspaceScreenState();
}

class _RoleWorkspaceScreenState extends State<RoleWorkspaceScreen> {
  int _selectedIndex = 0;

  late final List<AppShellDestination> _destinations;

  @override
  void initState() {
    super.initState();

    _destinations = const [
      AppShellDestination(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
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

  @override
  Widget build(BuildContext context) {
    return AppShell(
      roleLabel: widget.role,
      destinations: _destinations,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      onNotificationTap: () {
        // Notifications feature will be connected
        // once the API/UI module is implemented.
      },
      onProfileTap: () {
        // Profile route will be connected in the
        // shared profile slice.
      },
      child: _buildContent(
        context,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
  ) {
    switch (_selectedIndex) {
      case 1:
        return _ComingSoonPanel(
          icon: Icons.event_rounded,
          title: 'Events',
          description:
              'Your event discovery and participation space is coming next.',
        );

      case 2:
        return _ComingSoonPanel(
          icon: Icons.qr_code_2_rounded,
          title: 'Attendance',
          description:
              'QR-based attendance will be connected to the live backend next.',
        );

      case 3:
        return _ComingSoonPanel(
          icon: Icons.campaign_rounded,
          title: 'Updates',
          description:
              'Announcements and in-app notifications will appear here.',
        );

      case 0:
      default:
        return _DashboardPreview(
          role: widget.role,
          title: widget.title,
          subtitle: widget.subtitle,
        );
    }
  }
}

class _DashboardPreview extends StatelessWidget {
  final String role;
  final String title;
  final String subtitle;

  const _DashboardPreview({
    required this.role,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role.toUpperCase(),
            style: AppTextStyles.labelSmall(
              AppColors.secondary,
            ).copyWith(
              letterSpacing: 1.7,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            title,
            style: AppTextStyles.displayMedium(
              AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: Text(
              subtitle,
              style: AppTextStyles.bodyLarge(
                AppColors.darkTextSecondary,
              ),
            ),
          ),
          const SizedBox(
            height: 28,
          ),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Upcoming',
                  value: '—',
                  icon: Icons.event_available_rounded,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: _MetricCard(
                  label: 'Attendance',
                  value: '—',
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: _MetricCard(
                  label: 'Updates',
                  value: '—',
                  icon: Icons.campaign_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              AppDimens.space24,
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
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CampusConnect is ready.',
                        style: AppTextStyles.titleMedium(
                          AppColors.darkTextPrimary,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'This workspace will now be connected to the live platform modules.',
                        style: AppTextStyles.bodyMedium(
                          AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        18,
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
          Icon(
            icon,
            size: 21,
            color: AppColors.secondary,
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            value,
            style: AppTextStyles.headlineMedium(
              AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall(
              AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ComingSoonPanel({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            32,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(
                    22,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                title,
                style: AppTextStyles.headlineMedium(
                  AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(
                  AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
