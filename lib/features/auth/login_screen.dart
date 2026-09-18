import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/errors/failures.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';

import '../../widgets/app_button.dart';
import '../../features/auth/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late final AuthController _authController;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late final AnimationController _entranceController;
  late final AnimationController _glowController;

  late final Animation<double> _logoScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _authController = Get.find<AuthController>();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    _contentFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(
        0.18,
        0.95,
        curve: Curves.easeOut,
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(
          0.18,
          0.95,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocus.dispose();
    _passwordFocus.dispose();

    _entranceController.dispose();
    _glowController.dispose();

    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _authController.clearError();

    final success = await _authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      // IMPORTANT:
      // Login does NOT decide whether this is SUPER_ADMIN, ADMIN,
      // CORE_TEAM, MEMBER or STUDENT.
      //
      // Authentication succeeds first.
      // The role gateway will inspect the backend-returned roles
      // and send the user to the correct workspace.
      Get.offNamed(
        AppRoutes.roleGateway,
      );

      return;
    }

    final failure = _authController.lastFailure.value;

    _showLoginError(failure);
  }

  void _showLoginError(Failure? failure) {
    String message = 'Unable to sign in. Please try again.';

    if (failure is UnauthorizedFailure) {
      message = 'Email or password is incorrect.';
    } else if (failure is NetworkFailure) {
      message = 'Unable to reach Campus Connect. Check your connection.';
    } else if (failure is ValidationFailure) {
      message = failure.message;
    } else if (failure is ServerFailure) {
      message = failure.message;
    } else if (failure != null) {
      message = failure.message;
    }

    Get.snackbar(
      'Sign in failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      backgroundColor: AppColors.darkSurfaceElevated,
      colorText: AppColors.darkTextPrimary,
      icon: const Icon(
        Icons.error_outline_rounded,
        color: AppColors.error,
      ),
      duration: const Duration(seconds: 3),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _AnimatedBackground(
            animation: _glowController,
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    20,
                    24,
                    32 + bottomInset,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 20,
                    ),
                    child: Center(
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 440,
                            ),
                            child: _buildContent(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18),

          // ═══════════════════════════════════════════════════════
          // LOGO
          // ═══════════════════════════════════════════════════════

          Center(
            child: ScaleTransition(
              scale: _logoScale,
              child: const _CampusConnectLogo(),
            ),
          ),

          const SizedBox(height: 28),

          // ═══════════════════════════════════════════════════════
          // HEADER
          // ═══════════════════════════════════════════════════════

          const Text(
            'Welcome back.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Sign in to continue to Campus Connect',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.1,
            ),
          ),

          const SizedBox(height: 34),

          // ═══════════════════════════════════════════════════════
          // LOGIN CARD
          // ═══════════════════════════════════════════════════════

          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 18,
                sigmaY: 18,
              ),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface.withValues(
                    alpha: 0.82,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.darkBorderBright.withValues(
                      alpha: 0.55,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Account',
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _PremiumTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      label: 'Email address',
                      hint: 'you@campusconnect.dev',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: true,
                      onSubmitted: (_) {
                        _passwordFocus.requestFocus();
                      },
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Enter your email address';
                        }

                        final emailRegex = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );

                        if (!emailRegex.hasMatch(email)) {
                          return 'Enter a valid email address';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _PremiumTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !_authController.isLoading.value,
                      onSubmitted: (_) => _login(),
                      suffix: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.darkTextTertiary,
                          size: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your password';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _authController.isLoading.value
                            ? null
                            : () {
                                Get.toNamed(
                                  AppRoutes.forgotPassword,
                                );
                              },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                        ),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Reactive loading state.
                    Obx(
                      () => _buildSignInButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          TextButton.icon(
            onPressed: _authController.isLoading.value ? null : () => Get.toNamed(AppRoutes.register),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('New student? Create an account'),
          ),

          const SizedBox(height: 8),

          // ═══════════════════════════════════════════════════════
          // SECURITY NOTE
          // ═══════════════════════════════════════════════════════

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 15,
                color: AppColors.darkTextTertiary,
              ),
              const SizedBox(width: 7),
              Text(
                'Secure campus access',
                style: TextStyle(
                  color: AppColors.darkTextTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'CAMPUS CONNECT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.darkTextTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return AppButton(
      label: 'Sign in',
      isLoading: _authController.isLoading.value,
      isFullWidth: true,
      size: AppButtonSize.large,
      icon: Icons.arrow_forward_rounded,
      onPressed: _authController.isLoading.value ? null : _login,
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// PREMIUM TEXT FIELD
// ═════════════════════════════════════════════════════════════════

class _PremiumTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool enabled;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  const _PremiumTextField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.validator,
    this.onSubmitted,
  });

  @override
  State<_PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<_PremiumTextField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {
        _focused = widget.focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _focused
        ? AppColors.primary.withValues(alpha: 0.75)
        : AppColors.darkBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          validator: widget.validator,
          onFieldSubmitted: widget.onSubmitted,
          cursorColor: AppColors.secondary,
          style: const TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: AppColors.darkTextTertiary,
              fontSize: 13,
            ),
            prefixIcon: Icon(
              widget.icon,
              color:
                  _focused ? AppColors.secondary : AppColors.darkTextTertiary,
              size: 20,
            ),
            suffixIcon: widget.suffix,
            filled: true,
            fillColor: AppColors.darkSurfaceElevated.withValues(
              alpha: 0.72,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.darkBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.darkBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: borderColor,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// CAMPUS CONNECT LOGO
// ═════════════════════════════════════════════════════════════════

class _CampusConnectLogo extends StatelessWidget {
  const _CampusConnectLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceElevated,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(
          color: AppColors.darkBorderBright.withValues(
            alpha: 0.7,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 32,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.07),
            blurRadius: 42,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _CampusConnectLogoPainter(),
      ),
    );
  }
}

class _CampusConnectLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [
          AppColors.accent,
          AppColors.primary,
          AppColors.secondary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    // Left bracket: <
    final leftPath = Path()
      ..moveTo(center.dx - 25, center.dy - 12)
      ..lineTo(center.dx - 36, center.dy)
      ..lineTo(center.dx - 25, center.dy + 12);

    canvas.drawPath(leftPath, paint);

    // Right bracket: >
    final rightPath = Path()
      ..moveTo(center.dx + 25, center.dy - 12)
      ..lineTo(center.dx + 36, center.dy)
      ..lineTo(center.dx + 25, center.dy + 12);

    canvas.drawPath(rightPath, paint);

    // Main connection line.
    canvas.drawLine(
      Offset(center.dx - 24, center.dy),
      Offset(center.dx + 24, center.dy),
      paint,
    );

    // Vertical connection.
    canvas.drawLine(
      Offset(center.dx, center.dy - 24),
      Offset(center.dx, center.dy + 24),
      paint,
    );

    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        colors: [
          AppColors.accent,
          AppColors.secondary,
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: 28,
        ),
      );

    // Main node.
    canvas.drawCircle(
      center,
      6,
      nodePaint,
    );

    // Side nodes.
    canvas.drawCircle(
      Offset(center.dx - 24, center.dy),
      4,
      nodePaint,
    );

    canvas.drawCircle(
      Offset(center.dx + 24, center.dy),
      4,
      nodePaint,
    );

    // Top node.
    canvas.drawCircle(
      Offset(center.dx, center.dy - 24),
      3,
      nodePaint,
    );

    // Bottom node.
    canvas.drawCircle(
      Offset(center.dx, center.dy + 24),
      3,
      nodePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ═════════════════════════════════════════════════════════════════
// BACKGROUND
// ═════════════════════════════════════════════════════════════════

class _AnimatedBackground extends StatelessWidget {
  final Animation<double> animation;

  const _AnimatedBackground({
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;

        return Stack(
          children: [
            Positioned(
              top: -150 + (t * 35),
              right: -120,
              child: _GlowOrb(
                size: 300,
                color: AppColors.primary,
              ),
            ),
            Positioned(
              bottom: -180 - (t * 30),
              left: -130,
              child: _GlowOrb(
                size: 320,
                color: AppColors.secondary,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.42,
              left: -180 + (t * 30),
              child: _GlowOrb(
                size: 240,
                color: AppColors.accent,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: 70,
          sigmaY: 70,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.075),
          ),
        ),
      ),
    );
  }
}
