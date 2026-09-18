import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/layouts/app_shell.dart';
import '../../shared/widgets/role_dashboard_widgets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'event_controller.dart';
import 'event_detail_screen.dart';
import 'event_form_screen.dart';
import 'event_model.dart';
import 'event_widgets.dart';

class EventListScreen extends StatefulWidget {
  final String role;
  final bool embedded;

  const EventListScreen({
    super.key,
    required this.role,
    this.embedded = false,
  });

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late final EventController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<EventController>()
        ? Get.find<EventController>()
        : Get.put(
            EventController(),
          );
  }

  bool get canManageEvents =>
      widget.role == 'ADMIN' || widget.role == 'SUPER_ADMIN' || widget.role == 'CORE_TEAM';

  bool get isParticipant => widget.role == 'STUDENT' || widget.role == 'MEMBER';

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildPage(context);
    }

    return AppShell(
      roleLabel: widget.role,
      destinations: _destinations(),
      selectedIndex: 1,
      onDestinationSelected: _onDestinationSelected,
      onNotificationTap: () {},
      onProfileTap: () {},
      child: _buildPage(context),
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

  void _onDestinationSelected(
    int index,
  ) {
    if (index == 1) {
      return;
    }

    if (index == 0) {
      Get.back();
    }
  }

  Widget _buildPage(
    BuildContext context,
  ) {
    return Obx(
      () {
        final filtered = controller.filteredEvents;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(
              height: AppDimens.space20,
            ),
            _buildFilters(),
            const SizedBox(
              height: AppDimens.space20,
            ),
            Expanded(
              child: controller.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : filtered.isEmpty
                      ? DashboardEmptyCard(
                          icon: Icons.event_busy_outlined,
                          title: 'No events found',
                          description:
                              'Try another search or clear the current filters.',
                          actionLabel: 'Clear filters',
                          onAction: controller.clearFilters,
                        )
                      : RefreshIndicator(
                          color: AppColors.secondary,
                          onRefresh: controller.refreshEvents,
                          child: _buildEventGrid(
                            filtered,
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
  ) {
    return Row(
      children: [
        const Expanded(
          child: DashboardHeader(
            eyebrow: 'Campus activities',
            title: 'Events',
            subtitle: 'Discover what is happening across CampusConnect.',
          ),
        ),
        if (canManageEvents)
          FilledButton.icon(
            onPressed: () {
              Get.to(
                () => EventFormScreen(
                  controller: controller,
                  role: widget.role,
                ),
              );
            },
            icon: const Icon(
              Icons.add_rounded,
            ),
            label: const Text(
              'Create event',
            ),
          ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.setSearch,
            style: AppTextStyles.bodyMedium(
              AppColors.darkTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Search events...',
              hintStyle: AppTextStyles.bodyMedium(
                AppColors.darkTextTertiary,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: AppDimens.space12,
        ),
        PopupMenuButton<EventStatus?>(
          color: AppColors.darkSurfaceElevated,
          onSelected: controller.setStatusFilter,
          itemBuilder: (context) => [
            const PopupMenuItem<EventStatus?>(
              value: null,
              child: Text('All statuses'),
            ),
            const PopupMenuItem<EventStatus>(
              value: EventStatus.upcoming,
              child: Text('Upcoming'),
            ),
            const PopupMenuItem<EventStatus>(
              value: EventStatus.ongoing,
              child: Text('Ongoing'),
            ),
            const PopupMenuItem<EventStatus>(
              value: EventStatus.completed,
              child: Text('Completed'),
            ),
          ],
          child: Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(
                AppDimens.radiusMedium,
              ),
              border: Border.all(
                color: AppColors.darkBorder,
              ),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.darkTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventGrid(
    List<EventModel> events,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1250
            ? 3
            : constraints.maxWidth >= 800
                ? 2
                : 1;

        final spacing = AppDimens.space16;

        final cardWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        Widget card(EventModel event) {
          return EventCard(
            event: event,
            ownAttendanceLabel: controller.ownAttendanceLabels[event.id],
            showPrimaryAction: true,
            primaryActionLabel: canManageEvents
                ? 'Manage'
                : isParticipant
                    ? 'View'
                    : 'Details',
            onTap: () {
              Get.to(() => EventDetailScreen(
                eventId: event.id,
                role: widget.role,
                controller: controller,
                embedded: true,
              ));
            },
            onPrimaryAction: () {
              Get.to(() => EventDetailScreen(
                eventId: event.id,
                role: widget.role,
                controller: controller,
                embedded: true,
              ));
            },
          );
        }

        if (columns == 1) {
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 30),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, index) => card(events[index]),
          );
        }

        return GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 30),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 0.92,
          ),
          itemCount: events.length,
          itemBuilder: (_, index) => card(events[index]),
        );
      },
    );
  }
}
