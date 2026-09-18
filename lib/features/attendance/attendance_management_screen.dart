import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/events/event_controller.dart';
import '../../features/events/event_model.dart';
import '../../shared/layouts/app_shell.dart';
import '../../shared/widgets/role_dashboard_widgets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'attendance_controller.dart';
import 'attendance_model.dart';

class AttendanceManagementScreen extends StatefulWidget {
  final String role;
  final bool embedded;
  const AttendanceManagementScreen({super.key, required this.role, this.embedded = false});
  @override
  State<AttendanceManagementScreen> createState() => _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
  late final AttendanceController controller;
  late final EventController eventController;
  String? selectedEventId;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AttendanceController>() ? Get.find<AttendanceController>() : Get.put(AttendanceController());
    eventController = Get.isRegistered<EventController>() ? Get.find<EventController>() : Get.put(EventController());
    ever<List<EventModel>>(eventController.events, (events) {
      if (selectedEventId == null && events.isNotEmpty) {
        selectedEventId = events.first.id;
        controller.loadEventAttendance(events.first.id);
      }
    });
    if (eventController.events.isNotEmpty) {
      selectedEventId = eventController.events.first.id;
      controller.loadEventAttendance(selectedEventId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildContent();
    }

    return AppShell(
      roleLabel: widget.role,
      destinations: const [
        AppShellDestination(label: 'Dashboard', icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded),
        AppShellDestination(label: 'Events', icon: Icons.event_outlined, activeIcon: Icons.event_rounded),
        AppShellDestination(label: 'Attendance', icon: Icons.fact_check_outlined, activeIcon: Icons.fact_check_rounded),
        AppShellDestination(label: 'Updates', icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded),
      ],
      selectedIndex: 2,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardHeader(
          eyebrow: 'Event operations',
          title: 'Attendance',
          subtitle: 'Select an event to review and manage its attendance records.',
        ),
        const SizedBox(height: AppDimens.space16),
        _eventSelector(),
        const SizedBox(height: AppDimens.space18),
        _buildStats(),
        const SizedBox(height: AppDimens.space18),
        Expanded(
          child: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : controller.records.isEmpty
                  ? const DashboardEmptyCard(
                      icon: Icons.fact_check_outlined,
                      title: 'No attendance yet',
                      description: 'Attendance records will appear here when participants check in.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 30),
                      itemCount: controller.filteredRecords.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) => _record(controller.filteredRecords[index]),
                    ),
        ),
      ],
    ));
  }

  Widget _eventSelector() {
    final events = eventController.events.toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedEventId,
          dropdownColor: AppColors.darkSurfaceElevated,
          hint: const Text('Select event'),
          items: events.map((event) => DropdownMenuItem<String>(value: event.id, child: Text(event.title))).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => selectedEventId = value);
            controller.loadEventAttendance(value);
          },
        ),
      ),
    );
  }

  Widget _buildStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 620 ? 2 : 4;
        final gap = 12.0;
        final width = (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
          childAspectRatio: columns == 2 ? 1.12 : 1.35,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _metric('Present', '${controller.presentCount}', Icons.check_circle_outline_rounded, AppColors.success, width),
            _metric('Late', '${controller.lateCount}', Icons.schedule_rounded, AppColors.warning, width),
            _metric('Absent', '${controller.absentCount}', Icons.cancel_outlined, AppColors.error, width),
            _metric('Total', '${controller.records.length}', Icons.groups_outlined, AppColors.secondary, width),
          ],
        );
      },
    );
  }

  Widget _metric(String label, String value, IconData icon, Color color, double width) {
    return SizedBox(
      width: width,
      child: DashboardMetricCard(
        label: label,
        value: value,
        supportingText: 'Current event',
        icon: icon,
        accentColor: color,
      ),
    );
  }

  Widget _record(AttendanceModel record) {
    final color = _statusColor(record.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(record.userName.isEmpty ? '?' : record.userName[0].toUpperCase(), style: AppTextStyles.labelLarge(Colors.white)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(record.userName, style: AppTextStyles.titleMedium(AppColors.darkTextPrimary)),
          const SizedBox(height: 3),
          Text(record.userEmail, style: AppTextStyles.bodySmall(AppColors.darkTextTertiary)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppDimens.radiusFull)), child: Text(record.statusLabel, style: AppTextStyles.labelSmall(color))),
        const SizedBox(width: 8),
        PopupMenuButton<AttendanceStatus>(
          color: AppColors.darkSurfaceElevated,
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.darkTextSecondary),
          onSelected: (status) => controller.updateStatus(record.id, status),
          itemBuilder: (_) => const [
            PopupMenuItem(value: AttendanceStatus.present, child: Text('Present')),
            PopupMenuItem(value: AttendanceStatus.absent, child: Text('Absent')),
            PopupMenuItem(value: AttendanceStatus.late, child: Text('Late')),
            PopupMenuItem(value: AttendanceStatus.excused, child: Text('Excused')),
          ],
        ),
      ]),
    );
  }

  Color _statusColor(AttendanceStatus status) => switch (status) {
    AttendanceStatus.present => AppColors.success,
    AttendanceStatus.absent => AppColors.error,
    AttendanceStatus.late => AppColors.warning,
    AttendanceStatus.excused => AppColors.info,
  };
}
