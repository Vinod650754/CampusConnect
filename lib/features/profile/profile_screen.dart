import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/layouts/app_shell.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_controller.dart';
import '../auth/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  final String role;
  final bool embedded;

  const ProfileScreen({
    super.key,
    required this.role,
    this.embedded = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(
            ProfileController(),
          );
  }

  Widget _profileContent() {
    return Obx(
      () {
        final user = controller.profile.value;

        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return _buildContent(
          user,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _profileContent();
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
      selectedIndex: 0,
      child: _profileContent(),
    );
  }

  Widget _buildContent(
    dynamic user,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR ACCOUNT',
            style: AppTextStyles.labelSmall(
              AppColors.secondary,
            ).copyWith(
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Profile',
            style: AppTextStyles.displayMedium(
              AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              24,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(
                26,
              ),
            ),
            child: Row(
              children: [
                _avatar(
                  user.avatarUrl,
                  user.fullName,
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: AppTextStyles.headlineMedium(
                          Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        user.email,
                        style: AppTextStyles.bodySmall(
                          Colors.white.withValues(
                            alpha: 0.78,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 9,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.11,
                          ),
                          borderRadius: BorderRadius.circular(
                            30,
                          ),
                        ),
                        child: Text(
                          user.role,
                          style: AppTextStyles.labelSmall(
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          _infoPanel(
            user,
          ),
          const SizedBox(
            height: 16,
          ),
          _actionPanel(),
        ],
      ),
    );
  }

  Widget _avatar(
    String? url,
    String name,
  ) {
    return Container(
      width: 78,
      height: 78,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: ClipOval(
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initials(
                  name,
                ),
              )
            : _initials(
                name,
              ),
      ),
    );
  }

  Widget _initials(
    String name,
  ) {
    final initial = name.isEmpty ? 'U' : name[0].toUpperCase();

    return Center(
      child: Text(
        initial,
        style: AppTextStyles.headlineMedium(
          AppColors.primary,
        ),
      ),
    );
  }

  Widget _infoPanel(
    dynamic user,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        20,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(
          22,
        ),
        border: Border.all(
          color: AppColors.darkBorder,
        ),
      ),
      child: Column(
        children: [
          _row(
            'Phone',
            user.phone ?? 'Not added',
          ),
          _divider(),
          _row(
            'Department',
            user.department ?? 'Not added',
          ),
          _divider(),
          _row(
            'Roll number',
            user.rollNumber ?? 'Not added',
          ),
          _divider(),
          _row(
            'Bio',
            user.bio ?? 'No bio added',
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.labelSmall(
              AppColors.darkTextTertiary,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: AppTextStyles.bodyMedium(
              AppColors.darkTextPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Divider(
      color: AppColors.darkBorder,
      height: 24,
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access CampusConnect.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final auth = Get.find<AuthController>();
    final success = await auth.logout();

    if (!mounted) {
      return;
    }

    if (!success && auth.lastFailure.value != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.lastFailure.value!.message),
        ),
      );
    }
  }

  Widget _actionPanel() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Get.to(
                () => EditProfileScreen(
                  controller: controller,
                ),
              );
            },
            icon: const Icon(
              Icons.edit_outlined,
            ),
            label: const Text(
              'Edit profile',
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Get.to(
                () => ChangePasswordScreen(),
              );
            },
            icon: const Icon(
              Icons.lock_outline_rounded,
            ),
            label: const Text(
              'Change password',
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
            ),
            label: const Text(
              'Log out',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
