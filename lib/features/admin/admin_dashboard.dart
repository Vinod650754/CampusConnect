import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/layouts/app_shell.dart';
import '../../shared/widgets/role_dashboard_widgets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../announcements/announcement_list_screen.dart';
import '../attendance/attendance_management_screen.dart';
import '../events/event_list_screen.dart';
import '../people/people_screen.dart';
import '../gallery/gallery_screen.dart';
import '../profile/profile_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  static const _destinations = [
    AppShellDestination(label: 'Dashboard', icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded),
    AppShellDestination(label: 'Events', icon: Icons.event_outlined, activeIcon: Icons.event_rounded),
    AppShellDestination(label: 'People', icon: Icons.groups_outlined, activeIcon: Icons.groups_rounded),
    AppShellDestination(label: 'Gallery', icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library_rounded),
    AppShellDestination(label: 'Updates', icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded),
    AppShellDestination(label: 'Me', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded),
  ];

  @override Widget build(BuildContext context) => AppShell(
    roleLabel: 'ADMIN', destinations: _destinations, selectedIndex: _selectedIndex,
    onDestinationSelected: (i) => setState(() => _selectedIndex = i),
    child: _page(),
  );

  Widget _page() {
    switch (_selectedIndex) {
      case 1: return const EventListScreen(role: 'ADMIN', embedded: true);
      case 2: return const PeopleScreen(embedded: true);
      case 3: return const GalleryScreen(role: 'ADMIN', embedded: true);
      case 4: return const AnnouncementListScreen(role: 'ADMIN', embedded: true);
      case 5: return const ProfileScreen(role: 'ADMIN', embedded: true);
      default: return _dashboard();
    }
  }

  Widget _dashboard() => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const DashboardHeader(eyebrow: 'Administration', title: 'Campus operations.', subtitle: 'Manage people, events, attendance and campus-wide updates from one workspace.'),
      const SizedBox(height: AppDimens.space24),
      Wrap(spacing: 12, runSpacing: 12, children: const [
        SizedBox(width: 250, child: DashboardMetricCard(label: 'Event management', value: 'Live', supportingText: 'Create, edit, publish and remove events', icon: Icons.event_available_rounded)),
        SizedBox(width: 250, child: DashboardMetricCard(label: 'People', value: 'Live', supportingText: 'Search users and manage permitted roles', icon: Icons.groups_rounded, accentColor: AppColors.accent)),
        SizedBox(width: 250, child: DashboardMetricCard(label: 'Attendance', value: 'Live', supportingText: 'Review and update event attendance', icon: Icons.fact_check_outlined, accentColor: AppColors.success)),
        SizedBox(width: 250, child: DashboardMetricCard(label: 'Updates', value: 'Live', supportingText: 'Publish and manage announcements', icon: Icons.campaign_outlined, accentColor: AppColors.warning)),
      ]),
      const SizedBox(height: AppDimens.space28),
      const SectionTitle(title: 'Quick actions', subtitle: 'Open the real management tools.'),
      const SizedBox(height: AppDimens.space16),
      Wrap(spacing: 12, runSpacing: 12, children: [
        SizedBox(width: 300, child: QuickActionCard(title: 'Events', subtitle: 'Create, edit, publish and delete events.', icon: Icons.event_rounded, onTap: () => setState(() => _selectedIndex = 1))),
        SizedBox(width: 300, child: QuickActionCard(title: 'People', subtitle: 'Search users and manage allowed roles.', icon: Icons.manage_accounts_rounded, onTap: () => setState(() => _selectedIndex = 2))),
        SizedBox(width: 300, child: QuickActionCard(title: 'Attendance', subtitle: 'Review attendance records for an event.', icon: Icons.fact_check_rounded, onTap: () => Get.to(() => const AttendanceManagementScreen(role: 'ADMIN')))),
        SizedBox(width: 300, child: QuickActionCard(title: 'Gallery', subtitle: 'Upload and manage event photos.', icon: Icons.photo_library_rounded, onTap: () => setState(() => _selectedIndex = 3))),
        SizedBox(width: 300, child: QuickActionCard(title: 'Updates', subtitle: 'Create, publish and manage announcements.', icon: Icons.campaign_rounded, onTap: () => setState(() => _selectedIndex = 4))),
        SizedBox(width: 300, child: QuickActionCard(title: 'Profile', subtitle: 'Edit your account, password or log out.', icon: Icons.person_rounded, onTap: () => setState(() => _selectedIndex = 5))),
      ]),
    ]),
  );
}
