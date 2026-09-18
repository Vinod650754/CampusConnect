import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/layouts/app_shell.dart';
import '../../shared/widgets/role_dashboard_widgets.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'announcement_controller.dart';
import 'announcement_detail_screen.dart';
import 'announcement_form_screen.dart';
import 'announcement_widgets.dart';

class AnnouncementListScreen extends StatefulWidget {
  final String role;
  final bool embedded;

  const AnnouncementListScreen({
    super.key,
    required this.role,
    this.embedded = false,
  });

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  late final AnnouncementController controller;

  bool get canManage =>
      widget.role == 'SUPER_ADMIN' ||
      widget.role == 'ADMIN' ||
      widget.role == 'CORE_TEAM';

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<AnnouncementController>()
        ? Get.find<AnnouncementController>()
        : Get.put(
            AnnouncementController(),
          );
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
      selectedIndex: 3,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: DashboardHeader(
                  eyebrow: 'Campus updates',
                  title: 'Announcements',
                  subtitle:
                      'Stay informed about what is happening across CampusConnect.',
                ),
              ),
              if (canManage)
                FilledButton.icon(
                  onPressed: () {
                    Get.to(
                      () => AnnouncementFormScreen(
                        controller: controller,
                        role: widget.role,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.add_rounded,
                  ),
                  label: const Text(
                    'Create',
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: AppDimens.space20,
          ),
          TextField(
            onChanged: controller.setSearch,
            decoration: const InputDecoration(
              hintText: 'Search announcements...',
              prefixIcon: Icon(
                Icons.search_rounded,
              ),
            ),
          ),
          const SizedBox(
            height: AppDimens.space16,
          ),
          Expanded(
            child: controller.filteredAnnouncements.isEmpty
                ? const DashboardEmptyCard(
                    icon: Icons.campaign_outlined,
                    title: 'No announcements',
                    description:
                        'There are no announcements matching your search.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(
                      bottom: 30,
                    ),
                    itemCount: controller.filteredAnnouncements.length,
                    separatorBuilder: (_, __) => const SizedBox(
                      height: 12,
                    ),
                    itemBuilder: (_, index) {
                      final item = controller.filteredAnnouncements[index];

                      return AnnouncementCard(
                        announcement: item,
                        canManage: canManage,
                        onTap: () {
                          Get.to(
                            () => AnnouncementDetailScreen(
                              announcement: item,
                            ),
                          );
                        },
                        onEdit: canManage
                            ? () {
                                Get.to(
                                  () => AnnouncementFormScreen(
                                    controller: controller,
                                    role: widget.role,
                                    existing: item,
                                  ),
                                );
                              }
                            : null,
                        onDelete: canManage
                            ? () {
                                controller.deleteAnnouncement(
                                  item.id,
                                );
                              }
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
