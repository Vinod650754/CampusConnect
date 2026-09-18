import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import 'auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _roll = TextEditingController();
  final _department = TextEditingController();

  bool _obscure = true;

  AuthController get auth => Get.find<AuthController>();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _roll.dispose();
    _department.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    final ok = await auth.register(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      rollNumber: _roll.text.trim(),
      department: _department.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      Get.offNamed(AppRoutes.login);
      Get.snackbar(
        'Registration successful',
        'Your student account has been created. Sign in to continue.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: AppColors.darkSurfaceElevated,
        colorText: AppColors.darkTextPrimary,
      );
    } else {
      Get.snackbar(
        'Registration failed',
        auth.lastFailure.value?.message ?? 'Unable to create your account.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        backgroundColor: AppColors.darkSurfaceElevated,
        colorText: AppColors.darkTextPrimary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IconButton(
                      alignment: Alignment.centerLeft,
                      onPressed: Get.back,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create your student account',
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'New registrations are created as STUDENT accounts.',
                      style: TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _field(
                      _name,
                      'Full name',
                      'Enter your full name',
                      Icons.person_outline_rounded,
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Full name is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      _email,
                      'Email address',
                      'you@example.com',
                      Icons.alternate_email_rounded,
                      type: TextInputType.emailAddress,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _field(
                      _password,
                      'Password',
                      'At least 8 characters and one number',
                      Icons.lock_outline_rounded,
                      obscure: _obscure,
                      suffix: IconButton(
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                      validator: (value) {
                        final password = value ?? '';
                        if (password.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (!RegExp(r'\d').hasMatch(password)) {
                          return 'Password must contain at least one number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _field(
                      _roll,
                      'Roll number (optional)',
                      'Your college roll number',
                      Icons.badge_outlined,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      _department,
                      'Department (optional)',
                      'ISE / CSE / ECE ...',
                      Icons.school_outlined,
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => AppButton(
                        label: 'Create student account',
                        isLoading: auth.isLoading.value,
                        isFullWidth: true,
                        size: AppButtonSize.large,
                        icon: Icons.person_add_alt_1_rounded,
                        onPressed: auth.isLoading.value ? null : _register,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Get.offNamed(AppRoutes.login),
                      child: const Text('Already have an account? Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    TextInputType? type,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
      ),
    );
  }
}
