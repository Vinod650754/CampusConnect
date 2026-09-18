import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/network/api_client.dart';
import '../../repositories/event_repository.dart';
import '../../shared/layouts/app_shell.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'event_model.dart';

class AttendanceQrScreen extends StatefulWidget {
  final EventModel event;
  final String role;
  const AttendanceQrScreen({super.key, required this.event, required this.role});
  @override State<AttendanceQrScreen> createState() => _AttendanceQrScreenState();
}

class _AttendanceQrScreenState extends State<AttendanceQrScreen> {
  late final EventRepository repository;
  EventAttendanceQr? qr;
  String? error;
  bool loading = true;

  @override
  void initState() { super.initState(); repository = EventRepository(Get.find<ApiClient>()); _load(); }

  Future<void> _load() async {
    try {
      final result = await repository.getAttendanceQr(widget.event.id);
      if (mounted) setState(() { qr = result; loading = false; });
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); loading = false; });
    }
  }

  @override Widget build(BuildContext context) {
    final content = _content(context);
    return AppShell(
      roleLabel: widget.role,
      destinations: const [
        AppShellDestination(label: 'Dashboard', icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded),
        AppShellDestination(label: 'Events', icon: Icons.event_outlined, activeIcon: Icons.event_rounded),
        AppShellDestination(label: 'Attendance', icon: Icons.fact_check_outlined, activeIcon: Icons.fact_check_rounded),
        AppShellDestination(label: 'Updates', icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded),
        AppShellDestination(label: 'Me', icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded),
      ],
      selectedIndex: 1,
      child: content,
    );
  }

  Widget _content(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(error!, style: AppTextStyles.bodyMedium(AppColors.error))));
    final cards = <Widget>[];
    if (qr?.staffToken != null && (widget.role == 'ADMIN' || widget.role == 'SUPER_ADMIN')) {
      cards.add(_qrCard('CORE TEAM + MEMBER', 'Club staff scan this QR to record attendance.', qr!.staffToken!, AppColors.accent));
    }
    if (qr?.studentToken != null) {
      cards.add(_qrCard('STUDENT', 'Students scan this QR to record attendance.', qr!.studentToken!, AppColors.secondary));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Text('ATTENDANCE CONTROL', style: AppTextStyles.labelSmall(AppColors.secondary).copyWith(letterSpacing: 1.6)),
          const SizedBox(height: 7),
          Text('Permanent event QRs', style: AppTextStyles.displayMedium(AppColors.darkTextPrimary)),
          const SizedBox(height: 7),
          Text(widget.event.title, style: AppTextStyles.bodyLarge(AppColors.darkTextSecondary)),
          const SizedBox(height: 24),
          if (cards.isEmpty) const Text('No attendance QR is available for this role.', style: TextStyle(color: Colors.white70))
          else ...cards.expand((card) => [card, const SizedBox(height: 16)]),
        ],
      ),
    );
  }

  Widget _qrCard(String title, String subtitle, String token, Color accent) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.space20),
      decoration: BoxDecoration(color: AppColors.darkSurface, borderRadius: BorderRadius.circular(AppDimens.radiusXLarge), border: Border.all(color: AppColors.darkBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: accent.withValues(alpha: .12), borderRadius: BorderRadius.circular(13)), child: Icon(Icons.qr_code_2_rounded, color: accent)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.titleMedium(AppColors.darkTextPrimary)), const SizedBox(height: 4), Text(subtitle, style: AppTextStyles.bodySmall(AppColors.darkTextSecondary))]))]),
        const SizedBox(height: 20),
        Center(child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: QrImageView(data: token, size: 250))),
        const SizedBox(height: 16),
        Text('Permanent attendance QR for this event.', textAlign: TextAlign.center, style: AppTextStyles.bodySmall(AppColors.darkTextTertiary)),
      ]),
    );
  }
}
