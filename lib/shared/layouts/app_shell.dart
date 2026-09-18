import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/notifications/notification_controller.dart';
import '../../features/notifications/notification_list_screen.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/profile/profile_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';

class AppShell extends StatefulWidget {
  final String roleLabel;
  final Widget child;
  final List<AppShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const AppShell({
    super.key,
    required this.roleLabel,
    required this.child,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Widget _buildNotificationButton() {
  return Obx(
    () {
      final controller =
          Get.isRegistered<
                  NotificationController>()
              ? Get.find<
                  NotificationController>()
              : Get.put(
                  NotificationController(),
                );

      final count =
          controller.unreadCount;

      return Stack(
        clipBehavior:
            Clip.none,
        children: [
          _buildHeaderIcon(
            icon:
                Icons.notifications_none_rounded,
            onTap:
                widget.onNotificationTap ??
                    () {
                      Get.to(
                        () =>
                            const NotificationListScreen(),
                      );
                    },
          ),
          if (count > 0)
            Positioned(
              right: -2,
              top: -2,
              child:
                  Container(
                constraints:
                    const BoxConstraints(
                  minWidth: 17,
                  minHeight: 17,
                ),
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 4,
                ),
                decoration:
                    const BoxDecoration(
                  color:
                      AppColors.error,
                  shape:
                      BoxShape.circle,
                ),
                child:
                    Center(
                  child:
                      Text(
                    count >
                            9
                        ? '9+'
                        : '$count',
                    style:
                        AppTextStyles
                            .labelSmall(
                      Colors.white,
                    ).copyWith(
                      fontSize:
                          9,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
  final AuthController _authController = Get.find<AuthController>();

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(
    covariant AppShell oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
  }

  String get _displayName {
    final name = _authController.user?.fullName;

    if (name == null || name.trim().isEmpty) {
      return 'User';
    }

    return name.trim().split(' ').first;
  }

  String get _initial {
    final name = _displayName;

    if (name.isEmpty) {
      return 'U';
    }

    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final bool isDesktop = constraints.maxWidth >= 1100;

        final bool isTablet =
            constraints.maxWidth >= 720 && constraints.maxWidth < 1100;

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (isDesktop)
                    _buildDesktopSidebar(
                      context,
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        _buildTopBar(
                          context,
                          showFullNavigation: isDesktop,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              if (isTablet)
                                _buildTabletRail(
                                  context,
                                ),
                              Expanded(
                                child: _buildContent(
                                  context,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isDesktop && !isTablet)
                          _buildMobileNavigation(
                            context,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopSidebar(
    BuildContext context,
  ) {
    return Container(
      width: 264,
      margin: const EdgeInsets.all(
        AppDimens.space16,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(
          alpha: 0.92,
        ),
        borderRadius: BorderRadius.circular(
          AppDimens.radiusXLarge,
        ),
        border: Border.all(
          color: AppColors.darkBorder,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildBrand(
            context,
            compact: false,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _buildNavigationList(
              context,
              compact: false,
            ),
          ),
          _buildSidebarProfile(
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildTabletRail(
    BuildContext context,
  ) {
    return Container(
      width: 82,
      margin: const EdgeInsets.only(
        left: AppDimens.space12,
        bottom: AppDimens.space12,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(
          alpha: 0.92,
        ),
        borderRadius: BorderRadius.circular(
          AppDimens.radiusXLarge,
        ),
        border: Border.all(
          color: AppColors.darkBorder,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildBrand(
            context,
            compact: true,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildNavigationList(
              context,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context, {
    required bool showFullNavigation,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.space20,
        AppDimens.space16,
        AppDimens.space20,
        AppDimens.space12,
      ),
      child: Row(
        children: [
          if (!showFullNavigation)
            _buildBrand(
              context,
              compact: true,
            ),
          if (!showFullNavigation) const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GOOD DAY, ${_displayName.toUpperCase()}',
                  style: AppTextStyles.labelSmall(
                    AppColors.darkTextTertiary,
                  ).copyWith(
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.roleLabel,
                  style: AppTextStyles.titleLarge(
                    AppColors.darkTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          _buildNotificationButton(),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: widget.onProfileTap ?? () {
              Get.to(() => ProfileScreen(role: widget.roleLabel, embedded: false));
            },
            child: _buildAvatar(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimens.space12,
        0,
        AppDimens.space16,
        AppDimens.space16,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimens.radiusXLarge,
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.darkBackground,
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimens.space20,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationList(
    BuildContext context, {
    required bool compact,
  }) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
      ),
      itemCount: widget.destinations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        final destination = widget.destinations[index];

        final selected = index == _selectedIndex;

        return _NavigationTile(
          destination: destination,
          selected: selected,
          compact: compact,
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });

            widget.onDestinationSelected?.call(index);
          },
        );
      },
    );
  }

  Widget _buildMobileNavigation(
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimens.space12,
        0,
        AppDimens.space12,
        AppDimens.space12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(
          alpha: 0.96,
        ),
        borderRadius: BorderRadius.circular(
          AppDimens.radiusXLarge,
        ),
        border: Border.all(
          color: AppColors.darkBorder,
        ),
      ),
      child: Row(
        children: [
          for (int index = 0; index < widget.destinations.length; index++)
            Expanded(
              child: _MobileNavigationTile(
                destination: widget.destinations[index],
                selected: index == _selectedIndex,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });

                  widget.onDestinationSelected?.call(index);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBrand(
    BuildContext context, {
    required bool compact,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Row(
        mainAxisAlignment:
            compact ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              gradient: AppColors.logoGradient,
              borderRadius: BorderRadius.all(
                Radius.circular(
                  14,
                ),
              ),
            ),
            child: const Icon(
              Icons.hub_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CAMPUS',
                    style: AppTextStyles.labelLarge(
                      AppColors.darkTextPrimary,
                    ).copyWith(
                      letterSpacing: 1.3,
                    ),
                  ),
                  Text(
                    'CONNECT',
                    style: AppTextStyles.labelSmall(
                      AppColors.darkTextSecondary,
                    ).copyWith(
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarProfile(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceBright,
          borderRadius: BorderRadius.circular(
            AppDimens.radiusLarge,
          ),
          border: Border.all(
            color: AppColors.darkBorder,
          ),
        ),
        child: Row(
          children: [
            _buildAvatar(
              size: 38,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge(
                      AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.roleLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall(
                      AppColors.darkTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.darkTextTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar({
    double size = 42,
  }) {
    final avatarUrl = _authController.user?.avatarUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.logoGradient,
        border: Border.all(
          color: AppColors.darkBorderBright,
        ),
      ),
      child: avatarUrl != null && avatarUrl.trim().isNotEmpty
          ? ClipOval(
              child: Image.network(
                avatarUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    _initial,
                    style: AppTextStyles.labelLarge(
                      Colors.white,
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                _initial,
                style: AppTextStyles.labelLarge(
                  Colors.white,
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimens.radiusMedium,
        ),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(
              AppDimens.radiusMedium,
            ),
            border: Border.all(
              color: AppColors.darkBorder,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.darkTextSecondary,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class AppShellDestination {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const AppShellDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class _NavigationTile extends StatelessWidget {
  final AppShellDestination destination;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _NavigationTile({
    required this.destination,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        selected ? Colors.white : AppColors.darkTextSecondary;

    final Widget tile = AnimatedContainer(
      duration: const Duration(
        milliseconds: 180,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 0 : 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        gradient: selected ? AppColors.primaryGradient : null,
        color: selected
            ? AppColors.primary.withValues(
                alpha: 0.88,
              )
            : Colors.transparent,
        borderRadius: BorderRadius.circular(
          AppDimens.radiusMedium,
        ),
        border: selected
            ? Border.all(
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment:
            compact ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(
            selected ? destination.activeIcon : destination.icon,
            size: 20,
            color: foreground,
          ),
          if (!compact) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                destination.label,
                style: AppTextStyles.labelLarge(
                  foreground,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimens.radiusMedium,
        ),
        child: tile,
      ),
    );
  }
}

class _MobileNavigationTile extends StatelessWidget {
  final AppShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _MobileNavigationTile({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        selected ? AppColors.secondary : AppColors.darkTextTertiary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimens.radiusMedium,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? destination.activeIcon : destination.icon,
                size: 20,
                color: foreground,
              ),
              const SizedBox(height: 4),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall(
                  foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
