import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../repositories/registration_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'registration_model.dart';

class EventRegistrationManagementScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String role;

  const EventRegistrationManagementScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.role,
  });

  @override
  State<EventRegistrationManagementScreen> createState() => _EventRegistrationManagementScreenState();
}

class _EventRegistrationManagementScreenState extends State<EventRegistrationManagementScreen> {
  late final RegistrationRepository repository;
  List<RegistrationModel> registrations = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    repository = RegistrationRepository(Get.find<ApiClient>());
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { loading = true; error = null; });
    try {
      final page = await repository.forEvent(widget.eventId);
      if (mounted) setState(() { registrations = page.registrations; loading = false; });
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); loading = false; });
    }
  }

  Future<void> _update(RegistrationModel item, RegistrationStatus status) async {
    try {
      await repository.updateStatus(item.id, status.name.toUpperCase());
      await _load();
      if (mounted) {
        Get.snackbar(
          'Registration updated',
          '${item.userName} is now ${status.name}.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Update failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(widget.eventTitle),
        backgroundColor: AppColors.darkBackground,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          error!,
                          style: AppTextStyles.bodyMedium(AppColors.error),
                        ),
                      ),
                    ],
                  )
                : registrations.isEmpty
                    ? ListView(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(30),
                            child: Center(child: Text('No registrations yet.')),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppDimens.space16),
                        itemCount: registrations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final item = registrations[index];
                          final canChange = item.status == RegistrationStatus.pending ||
                              item.status == RegistrationStatus.waitlisted;
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.darkSurface,
                              borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.userName, style: AppTextStyles.titleMedium(AppColors.darkTextPrimary)),
                                      const SizedBox(height: 4),
                                      Text(item.userEmail, style: AppTextStyles.bodySmall(AppColors.darkTextTertiary)),
                                      const SizedBox(height: 8),
                                      Text(item.statusLabel.toUpperCase(), style: AppTextStyles.labelSmall(AppColors.secondary)),
                                    ],
                                  ),
                                ),
                                if (canChange)
                                  PopupMenuButton<RegistrationStatus>(
                                    onSelected: (status) => _update(item, status),
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: RegistrationStatus.confirmed, child: Text('Confirm')),
                                      PopupMenuItem(value: RegistrationStatus.cancelled, child: Text('Cancel')),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
