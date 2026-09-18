import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

import '../../theme/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentController = TextEditingController();

  final _newController = TextEditingController();

  final _confirmController = TextEditingController();

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'Change password',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(
            20,
          ),
          children: [
            _passwordField(
              controller: _currentController,
              label: 'Current password',
              obscure: _hideCurrent,
              onVisibilityChanged: () {
                setState(
                  () {
                    _hideCurrent = !_hideCurrent;
                  },
                );
              },
            ),
            const SizedBox(
              height: 14,
            ),
            _passwordField(
              controller: _newController,
              label: 'New password',
              obscure: _hideNew,
              onVisibilityChanged: () {
                setState(
                  () {
                    _hideNew = !_hideNew;
                  },
                );
              },
              validator: (value) {
                if (value == null || value.length < 8) {
                  return 'Password must contain at least 8 characters';
                }

                return null;
              },
            ),
            const SizedBox(
              height: 14,
            ),
            _passwordField(
              controller: _confirmController,
              label: 'Confirm password',
              obscure: _hideConfirm,
              onVisibilityChanged: () {
                setState(
                  () {
                    _hideConfirm = !_hideConfirm;
                  },
                );
              },
              validator: (value) {
                if (value != _newController.text) {
                  return 'Passwords do not match';
                }

                return null;
              },
            ),
            const SizedBox(
              height: 24,
            ),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _save,
                child: const Text(
                  'Update password',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onVisibilityChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator ??
          (value) => value == null || value.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          onPressed: onVisibilityChanged,
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    final ok = await controller.changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );

    if (!ok) {
      Get.snackbar(
        'Password',
        controller.errorMessage.value ?? 'Password change failed.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.back();
    Get.snackbar(
      'Password',
      'Password changed successfully.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

}
