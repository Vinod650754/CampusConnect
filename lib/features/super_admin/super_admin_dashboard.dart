import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/super_admin_controller.dart';
import '../auth/auth_controller.dart';
import '../people/people_screen.dart';
import '../announcements/announcement_list_screen.dart';
import '../attendance/attendance_management_screen.dart';
import '../certificates/certificate_list_screen.dart';
import '../events/event_list_screen.dart';
import '../gallery/gallery_screen.dart';
import '../profile/profile_screen.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final SuperAdminController _controller;
  final AuthController _authController = Get.find<AuthController>();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = Get.find<SuperAdminController>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _controller.loadOverview();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _displayName {
    final name = _authController.user?.fullName;

    if (name == null || name.trim().isEmpty) {
      return 'Administrator';
    }

    return name.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050506),
      body: SafeArea(
        child: Stack(
          children: [
            const _BackgroundGlow(),
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.035),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: _buildBody(),
                    ),
                  ),
                ),
                _buildBottomNavigation(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          const _CampusConnectLogo(size: 42),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CAMPUS CONNECT',
                  style: TextStyle(
                    color: Color(0xFFF5F5F7),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.7,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'SUPER ADMIN',
                  style: TextStyle(
                    color: Color(0xFF777781),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          _iconButton(
            Icons.notifications_none_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _profileButton(),
        ],
      ),
    );
  }

  Widget _profileButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = 4;
        });
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6D5DF6),
              Color(0xFF16C7C1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6D5DF6).withValues(alpha: 0.22),
              blurRadius: 18,
            ),
          ],
        ),
        child: Center(
          child: Text(
            _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'A',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF25252D),
          ),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFB9B9C2),
          size: 21,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BODY
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        return const PeopleScreen();

      case 2:
        return const EventListScreen(
          role: 'SUPER_ADMIN',
          embedded: true,
        );

      case 3:
        return const AnnouncementListScreen(
          role: 'SUPER_ADMIN',
          embedded: true,
        );

      case 4:
        return const ProfileScreen(
          role: 'SUPER_ADMIN',
          embedded: true,
        );

      case 0:
      default:
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              const SizedBox(height: 24),
              _buildOverviewCard(),
              const SizedBox(height: 22),
              _sectionTitle(
                'ORGANIZATION',
                'Your campus at a glance',
              ),
              const SizedBox(height: 14),
              _buildStatsGrid(),
              const SizedBox(height: 26),
              _sectionTitle(
                'QUICK ACCESS',
                'Jump into administration',
              ),
              const SizedBox(height: 14),
              _buildQuickActions(),
              const SizedBox(height: 26),
              _sectionTitle(
                'PLATFORM',
                'Access the rest of your administrative tools',
              ),
              const SizedBox(height: 14),
              _buildPlatformActions(),
              const SizedBox(height: 26),
              _sectionTitle(
                'ACTIVITY',
                'Organization activity',
              ),
              const SizedBox(height: 14),
              _buildActivityCard(),
              const SizedBox(height: 24),
            ],
          ),
        );
    }
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME BACK',
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hi, $_displayName 👋',
          style: const TextStyle(
            color: Color(0xFFF5F5F7),
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Manage CampusConnect from one place.',
          style: TextStyle(
            color: Color(0xFFAEAEB2),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAccount() {
    return Center(
      child: FilledButton.icon(
        onPressed: _authController.logout,
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Log out'),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // OVERVIEW
  // ═══════════════════════════════════════════════════════════════

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF14131B),
            Color(0xFF0A0A0D),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF292832),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D5DF6).withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF6D5DF6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.hub_rounded,
              color: Color(0xFF8B7DFF),
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Obx(() {
              final totalUsers = _controller.overview.value?.totalUsers;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CAMPUS OVERVIEW',
                    style: TextStyle(
                      color: Color(0xFF858590),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    totalUsers == null
                        ? 'Organization control center'
                        : '$totalUsers total people',
                    style: const TextStyle(
                      color: Color(0xFFEDEDF2),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            }),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Color(0xFF555560),
            size: 15,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STATS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildStatsGrid() {
    return Obx(() {
      final data = _controller.overview.value;

      if (_controller.isLoading.value && data == null) {
        return const SizedBox(
          height: 190,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF8B7DFF),
              ),
            ),
          ),
        );
      }

      if (_controller.failure.value != null && data == null) {
        return _buildOverviewError();
      }

      final stats = GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.42,
        children: [
          _statCard(
            icon: Icons.admin_panel_settings_outlined,
            label: 'ADMINS',
            value: '${data?.admins ?? 0}',
            accent: const Color(0xFF8B7DFF),
          ),
          _statCard(
            icon: Icons.groups_2_outlined,
            label: 'CORE TEAM',
            value: '${data?.coreTeam ?? 0}',
            accent: const Color(0xFF22C7C1),
          ),
          _statCard(
            icon: Icons.volunteer_activism_outlined,
            label: 'MEMBERS',
            value: '${data?.members ?? 0}',
            accent: const Color(0xFFE9A84B),
          ),
          _statCard(
            icon: Icons.school_outlined,
            label: 'STUDENTS',
            value: '${data?.students ?? 0}',
            accent: const Color(0xFF5E9EFF),
          ),
        ],
      );

      if (_controller.failure.value == null) {
        return stats;
      }

      return Column(
        children: [
          stats,
          const SizedBox(height: 12),
          _buildOverviewRetryAction(),
        ],
      );
    });
  }

  Widget _buildOverviewError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A2A32)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: Color(0xFFE9A84B),
            size: 26,
          ),
          const SizedBox(height: 10),
          const Text(
            'Could not load dashboard data',
            style: TextStyle(
              color: Color(0xFFEDEDF2),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF858590),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          _buildOverviewRetryAction(),
        ],
      ),
    );
  }

  Widget _buildOverviewRetryAction() {
    return TextButton.icon(
      onPressed: _controller.refreshOverview,
      icon: const Icon(Icons.refresh_rounded, size: 17),
      label: const Text('RETRY'),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF9B8FFF),
        textStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF232329),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: accent,
                size: 19,
              ),
              const Spacer(),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.55),
                      blurRadius: 7,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFF4F4F6),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF696972),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // QUICK ACCESS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _quickAction(
                icon: Icons.people_alt_outlined,
                title: 'People',
                subtitle: 'Users & roles',
                accent: const Color(0xFF8B7DFF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickAction(
                icon: Icons.event_outlined,
                title: 'Events',
                subtitle: 'All events',
                accent: const Color(0xFF22C7C1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _quickAction(
                icon: Icons.campaign_outlined,
                title: 'Announcements',
                subtitle: 'Campus updates',
                accent: const Color(0xFFE9A84B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickAction(
                icon: Icons.analytics_outlined,
                title: 'Reports',
                subtitle: 'Insights',
                accent: const Color(0xFF5E9EFF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          switch (title) {
            case 'People':
              setState(() => _selectedIndex = 1);
              break;
            case 'Events':
              setState(() => _selectedIndex = 2);
              break;
            case 'Announcements':
              setState(() => _selectedIndex = 3);
              break;
            default:
              break;
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF232329),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: accent,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFE8E8ED),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF686871),
                        fontSize: 9,
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

  // ═══════════════════════════════════════════════════════════════
  // ACTIVITY
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPlatformActions() {
    return Column(
      children: [
        _platformAction(
          icon: Icons.fact_check_outlined,
          title: 'Attendance management',
          subtitle: 'Review and correct event attendance.',
          onTap: () {
            Get.to(
              () => const AttendanceManagementScreen(
                role: 'SUPER_ADMIN',
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _platformAction(
          icon: Icons.photo_library_outlined,
          title: 'Gallery',
          subtitle: 'Manage CampusConnect event memories.',
          onTap: () {
            Get.to(
              () => const GalleryScreen(
                role: 'SUPER_ADMIN',
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        _platformAction(
          icon: Icons.workspace_premium_outlined,
          title: 'Certificates',
          subtitle: 'Issue and manage participation certificates.',
          onTap: () {
            Get.to(
              () => const CertificateListScreen(
                role: 'SUPER_ADMIN',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _platformAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D11),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF25252D),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF6D5DF6).withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF9B8FFF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFF1F1F4),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF777781),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Color(0xFF666670),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0F),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF232329),
        ),
      ),
      child: Column(
        children: [
          _activityRow(
            icon: Icons.insights_outlined,
            title: 'Organization activity',
            subtitle: 'Live activity will appear here',
            accent: const Color(0xFF8B7DFF),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              color: Color(0xFF202026),
              height: 1,
            ),
          ),
          _activityRow(
            icon: Icons.security_outlined,
            title: 'System status',
            subtitle: 'Authentication is active',
            accent: const Color(0xFF22C7C1),
          ),
        ],
      ),
    );
  }

  Widget _activityRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: accent,
            size: 20,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE5E5EA),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF66666F),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(
    String eyebrow,
    String title,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: Color(0xFF6D6D77),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFE8E8ED),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOTTOM NAVIGATION
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBottomNavigation() {
    const items = [
      _NavItem(
        icon: Icons.grid_view_rounded,
        label: 'Overview',
      ),
      _NavItem(
        icon: Icons.people_outline_rounded,
        label: 'People',
      ),
      _NavItem(
        icon: Icons.event_outlined,
        label: 'Events',
      ),
      _NavItem(
        icon: Icons.notifications_none_rounded,
        label: 'Activity',
      ),
      _NavItem(
        icon: Icons.person_outline_rounded,
        label: 'Me',
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF08080A).withValues(alpha: 0.96),
        border: const Border(
          top: BorderSide(
            color: Color(0xFF1D1D22),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (index) {
            final item = items[index];
            final selected = _selectedIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF6D5DF6).withValues(alpha: 0.10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: selected
                          ? const Color(0xFF9B8FFF)
                          : const Color(0xFF62626B),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFFB7AFFE)
                            : const Color(0xFF62626B),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// NAV ITEM
// ═════════════════════════════════════════════════════════════════

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}

// ═════════════════════════════════════════════════════════════════
// LOGO
// ═════════════════════════════════════════════════════════════════

class _CampusConnectLogo extends StatelessWidget {
  final double size;

  const _CampusConnectLogo({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(size * 0.30),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: CustomPaint(
        painter: _LogoPainter(),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final purple = Paint()
      ..color = const Color(0xFF8B7DFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final teal = Paint()
      ..color = const Color(0xFF22C7C1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final white = Paint()
      ..color = const Color(0xFFEDEDF2)
      ..style = PaintingStyle.fill;

    final left = Path()
      ..moveTo(center.dx - 6, center.dy - 8)
      ..lineTo(center.dx - 12, center.dy)
      ..lineTo(center.dx - 6, center.dy + 8);

    final right = Path()
      ..moveTo(center.dx + 6, center.dy - 8)
      ..lineTo(center.dx + 12, center.dy)
      ..lineTo(center.dx + 6, center.dy + 8);

    canvas.drawPath(left, purple);
    canvas.drawPath(right, teal);

    canvas.drawLine(
      Offset(center.dx - 4, center.dy),
      Offset(center.dx + 4, center.dy),
      white,
    );

    canvas.drawCircle(
      Offset(center.dx - 4, center.dy),
      2,
      white,
    );

    canvas.drawCircle(
      Offset(center.dx + 4, center.dy),
      2,
      white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ═════════════════════════════════════════════════════════════════
// BACKGROUND
// ═════════════════════════════════════════════════════════════════

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -180,
            right: -150,
            child: _glow(
              const Color(0xFF6D5DF6),
              360,
            ),
          ),
          Positioned(
            bottom: -240,
            left: -180,
            child: _glow(
              const Color(0xFF22C7C1),
              430,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.045),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
