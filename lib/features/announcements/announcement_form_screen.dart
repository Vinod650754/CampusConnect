import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';
import 'announcement_controller.dart';
import 'announcement_model.dart';

class AnnouncementFormScreen extends StatefulWidget {
  final AnnouncementController controller;
  final String role;
  final AnnouncementModel? existing;

  const AnnouncementFormScreen({
    super.key,
    required this.controller,
    required this.role,
    this.existing,
  });

  @override
  State<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;

  late final TextEditingController _contentController;

  late bool _isPinned;
  late bool _isPublished;

  final Set<AnnouncementTargetRole> _targets = <AnnouncementTargetRole>{};

  bool get canTargetCoreTeam =>
      widget.role == 'ADMIN' || widget.role == 'SUPER_ADMIN';

  @override
  void initState() {
    super.initState();

    final announcement = widget.existing;

    _titleController = TextEditingController(
      text: announcement?.title ?? '',
    );

    _contentController = TextEditingController(
      text: announcement?.content ?? '',
    );

    _isPinned = announcement?.isPinned ?? false;

    _isPublished = announcement?.isPublished ?? true;

    _targets.addAll(
      announcement?.targetRoles ?? const [],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'Create announcement' : 'Edit announcement',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(
            20,
          ),
          children: [
            _section(
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Important campus update',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 7,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'Write your announcement...',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Message is required';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target audience',
                    style: AppTextStyles.headlineMedium(
                      AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Choose who should receive this announcement.',
                    style: AppTextStyles.bodySmall(
                      AppColors.darkTextSecondary,
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  _targetTile(
                    AnnouncementTargetRole.student,
                    'Students',
                    Icons.school_outlined,
                  ),
                  _targetTile(
                    AnnouncementTargetRole.member,
                    'Members',
                    Icons.groups_outlined,
                  ),
                  if (canTargetCoreTeam)
                    _targetTile(
                      AnnouncementTargetRole.coreTeam,
                      'Core Team',
                      Icons.admin_panel_settings_outlined,
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            _section(
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Pin announcement',
                    ),
                    value: _isPinned,
                    onChanged: (value) {
                      setState(() {
                        _isPinned = value;
                      });
                    },
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Publish immediately',
                    ),
                    subtitle: const Text(
                      'Published announcements generate in-app notifications for their target audience.',
                    ),
                    value: _isPublished,
                    onChanged: (value) {
                      setState(() {
                        _isPublished = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(
                  Icons.send_rounded,
                ),
                label: Text(
                  widget.existing == null
                      ? 'Publish announcement'
                      : 'Save changes',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        20,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(
          AppDimens.radiusLarge,
        ),
        border: Border.all(
          color: AppColors.darkBorder,
        ),
      ),
      child: child,
    );
  }

  Widget _targetTile(
    AnnouncementTargetRole role,
    String label,
    IconData icon,
  ) {
    final selected = _targets.contains(
      role,
    );

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: selected,
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _targets.add(
              role,
            );
          } else {
            _targets.remove(
              role,
            );
          }
        });
      },
      secondary: Icon(
        icon,
        color: selected ? AppColors.secondary : AppColors.darkTextTertiary,
      ),
      title: Text(label),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_targets.isEmpty) {
      Get.snackbar(
        'Select an audience',
        'Choose at least one target audience.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    final existing = widget.existing;

    final announcement = AnnouncementModel(
      id: existing?.id ??
          'announcement-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      targetRoles: _targets.toList(),
      isPinned: _isPinned,
      isPublished: _isPublished,
      publishedAt:
          _isPublished ? existing?.publishedAt ?? DateTime.now() : null,
      createdAt: existing?.createdAt ?? DateTime.now(),
      authorName: widget.role,
    );

    if (existing == null) {
      final ok = await widget.controller.addAnnouncement(announcement);
      if (!ok) return;
    } else {
      final ok = await widget.controller.updateAnnouncement(announcement);
      if (!ok) return;
    }

    Get.back();
  }
}
