import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import 'certificate_controller.dart';
import 'certificate_model.dart';

class CertificateIssueScreen extends StatefulWidget {
  final CertificateController controller;

  const CertificateIssueScreen({
    super.key,
    required this.controller,
  });

  @override
  State<CertificateIssueScreen> createState() => _CertificateIssueScreenState();
}

class _CertificateIssueScreenState extends State<CertificateIssueScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  final _userController = TextEditingController();

  final _eventController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _userController.dispose();
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Issue certificate',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(
            20,
          ),
          children: [
            Container(
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
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Certificate title',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextFormField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      labelText: 'User ID',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  TextFormField(
                    controller: _eventController,
                    decoration: const InputDecoration(
                      labelText: 'Event ID',
                    ),
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(
                        Icons.workspace_premium_outlined,
                      ),
                      label: const Text(
                        'Issue certificate',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ok = await widget.controller.addCertificate(
      CertificateModel(
        id: 'certificate-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        certificateHash: DateTime.now()
            .millisecondsSinceEpoch
            .toRadixString(
              16,
            )
            .padLeft(
              64,
              '0',
            ),
        userId: _userController.text.trim(),
        userName: 'Selected User',
        eventId: _eventController.text.trim().isEmpty
            ? null
            : _eventController.text.trim(),
        eventTitle: 'CampusConnect Event',
        status: CertificateStatus.issued,
        issuedAt: DateTime.now(),
      ),
    );

    if (!ok) return;
    Get.back();
  }
}
