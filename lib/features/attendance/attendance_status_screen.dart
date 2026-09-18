import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../events/event_controller.dart';
import '../events/event_model.dart';
import '../../shared/layouts/app_shell.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'attendance_controller.dart';
import 'attendance_model.dart';

class AttendanceStatusScreen extends StatefulWidget {
  final String role;
  final bool embedded;
  const AttendanceStatusScreen({super.key, required this.role, this.embedded = false});
  @override
  State<AttendanceStatusScreen> createState() => _AttendanceStatusScreenState();
}

class _AttendanceStatusScreenState extends State<AttendanceStatusScreen> {
  late final EventController events;
  late final AttendanceController attendance;
  final RxList<_AttendanceItem> items = <_AttendanceItem>[].obs;
  final RxBool loading = true.obs;

  @override
  void initState() {
    super.initState();
    events = Get.isRegistered<EventController>() ? Get.find<EventController>() : Get.put(EventController());
    attendance = Get.isRegistered<AttendanceController>() ? Get.find<AttendanceController>() : Get.put(AttendanceController());
    _load();
  }

  Future<void> _load() async {
    loading.value = true;
    if (events.events.isEmpty) await events.loadEvents();
    final result = <_AttendanceItem>[];
    for (final event in events.events) {
      try {
        final own = await attendance.ownForUi(event.id); // extension helper below
        result.add(_AttendanceItem(event: event, label: own.label, status: own.attendance?.status));
      } catch (_) {
        result.add(_AttendanceItem(event: event, label: 'Not marked', status: null));
      }
    }
    items.assignAll(result);
    loading.value = false;
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
        AppShellDestination(label: 'Attend', icon: Icons.fact_check_outlined, activeIcon: Icons.fact_check_rounded),
        AppShellDestination(label: 'Updates', icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded),
      ],
      selectedIndex: 2,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final attended = items.where((i) => i.status == AttendanceStatus.present).length;
      final late = items.where((i) => i.status == AttendanceStatus.late).length;
      final upcoming = items.where((i) => i.event.startAt.isAfter(DateTime.now())).length;
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('YOUR PARTICIPATION', style: AppTextStyles.labelSmall(AppColors.secondary).copyWith(letterSpacing: 1.6)),
            const SizedBox(height: 8),
            Text('Attendance', style: AppTextStyles.displayMedium(AppColors.darkTextPrimary)),
            const SizedBox(height: 7),
            Text('Your live attendance status across CampusConnect events.', style: AppTextStyles.bodyLarge(AppColors.darkTextSecondary)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _summaryItem('$attended', 'Attended', AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: _summaryItem('$late', 'Late', AppColors.warning)),
              const SizedBox(width: 12),
              Expanded(child: _summaryItem('$upcoming', 'Upcoming', AppColors.info)),
            ]),
            const SizedBox(height: 24),
            ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _AttendanceCard(item: item))),
          ],
        ),
      );
    });
  }

  Widget _summaryItem(String value, String label, Color color) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(AppDimens.radiusLarge), border: Border.all(color: AppColors.darkBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: AppTextStyles.headlineLarge(color)),
      const SizedBox(height: 4),
      Text(label, style: AppTextStyles.labelLarge(AppColors.darkTextSecondary)),
    ]),
  );
}

class _AttendanceItem {
  final EventModel event;
  final String label;
  final AttendanceStatus? status;
  const _AttendanceItem({required this.event, required this.label, required this.status});
}

class _AttendanceCard extends StatelessWidget {
  final _AttendanceItem item;
  const _AttendanceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final status = item.status;
    final color = status == AttendanceStatus.present ? AppColors.success : status == AttendanceStatus.late ? AppColors.warning : status == AttendanceStatus.absent ? AppColors.error : AppColors.info;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(AppDimens.radiusLarge), border: Border.all(color: AppColors.darkBorder)),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)), child: Icon(status == AttendanceStatus.present ? Icons.check_rounded : status == AttendanceStatus.late ? Icons.schedule_rounded : Icons.fact_check_outlined, color: color)),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.event.title, style: AppTextStyles.titleMedium(AppColors.darkTextPrimary)),
          const SizedBox(height: 4),
          Text(DateFormat('dd MMM yyyy • hh:mm a').format(item.event.startAt), style: AppTextStyles.bodySmall(AppColors.darkTextTertiary)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppDimens.radiusFull)), child: Text(item.label, style: AppTextStyles.labelSmall(color))),
      ]),
    );
  }
}
