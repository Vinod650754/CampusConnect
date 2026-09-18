import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import '../events/event_controller.dart';
import '../registrations/registration_controller.dart';
import 'attendance_controller.dart';

class AttendanceScannerScreen extends StatefulWidget {
  final String role;
  final bool embedded;

  const AttendanceScannerScreen({
    super.key,
    required this.role,
    this.embedded = false,
  });

  @override
  State<AttendanceScannerScreen> createState() => _AttendanceScannerScreenState();
}

class _AttendanceScannerScreenState extends State<AttendanceScannerScreen> {
  late final AttendanceController controller;
  final MobileScannerController scannerController = MobileScannerController();
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AttendanceController>()
        ? Get.find<AttendanceController>()
        : Get.put(AttendanceController());
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanner = Stack(
      children: [
        MobileScanner(
          controller: scannerController,
          onDetect: _onDetect,
        ),
        SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const Spacer(),
              _buildScannerFrame(),
              const Spacer(),
              _buildBottomPanel(),
            ],
          ),
        ),
      ],
    );

    if (widget.embedded) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        child: scanner,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: scanner,
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.space16),
      child: Row(
        children: [
          if (!widget.embedded)
            IconButton(
              onPressed: Get.back,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.45),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          if (!widget.embedded) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ATTENDANCE',
                  style: AppTextStyles.labelSmall(
                    Colors.white.withValues(alpha: 0.7),
                  ).copyWith(letterSpacing: 1.5),
                ),
                const SizedBox(height: 2),
                Text(
                  'Scan QR',
                  style: AppTextStyles.titleLarge(Colors.white),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: scannerController.toggleTorch,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.45),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.flash_on_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerFrame() {
    return Container(
      width: 270,
      height: 270,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Stack(
        children: [
          Positioned(left: -3, top: 36, child: _corner()),
          Positioned(
            right: -3,
            top: 36,
            child: Transform.rotate(angle: 1.5708, child: _corner()),
          ),
          Positioned(
            left: -3,
            bottom: 36,
            child: Transform.rotate(angle: -1.5708, child: _corner()),
          ),
          Positioned(
            right: -3,
            bottom: 36,
            child: Transform.rotate(angle: 3.1416, child: _corner()),
          ),
        ],
      ),
    );
  }

  Widget _corner() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.secondary, width: 4),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.82),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.role == 'STUDENT'
                  ? 'Scan the student attendance QR'
                  : 'Scan the staff attendance QR',
              style: AppTextStyles.titleMedium(Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              widget.role == 'STUDENT'
                  ? 'Scan the student QR displayed by Admin or Core Team.'
                  : 'Scan the staff QR displayed by Admin to mark your attendance.',
              style: AppTextStyles.bodySmall(
                Colors.white.withValues(alpha: 0.68),
              ),
            ),
            if (controller.lastScanMessage.value != null) ...[
              const SizedBox(height: 14),
              Text(
                controller.lastScanMessage.value!,
                style: AppTextStyles.bodyMedium(AppColors.secondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;

    final barcode = capture.barcodes.firstOrNull;
    final value = barcode?.rawValue;
    if (value == null || value.trim().isEmpty) return;

    _handled = true;
    final success = await controller.scanDemoQr(value);

    if (!mounted) return;

    if (success) {
      if (Get.isRegistered<RegistrationController>()) {
        await Get.find<RegistrationController>().loadRegistrations();
      }
      if (Get.isRegistered<EventController>()) {
        await Get.find<EventController>().loadEvents();
      }
    }

    Get.snackbar(
      success ? 'Attendance recorded' : 'Attendance scan failed',
      controller.lastScanMessage.value ?? 'Unable to process the QR code.',
      snackPosition: SnackPosition.BOTTOM,
    );

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) _handled = false;
  }
}
