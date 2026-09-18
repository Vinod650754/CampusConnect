import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/auth/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _glowController;

  late final Animation<double> _markScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _markScale = Tween<double>(
      begin: 0.72,
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
        0.28,
        0.82,
        curve: Curves.easeOut,
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(
          0.28,
          0.90,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _entranceController.forward();

    // Start session restoration immediately.
    _initializeSession();
  }

  // ═══════════════════════════════════════════════════════════════
  // SESSION INITIALIZATION
  // ═══════════════════════════════════════════════════════════════

  Future<void> _initializeSession() async {
    final authController = Get.find<AuthController>();

    // Give the splash enough time to show its animation.
    final splashDelay = Future<void>.delayed(
      const Duration(milliseconds: 1600),
    );

    // This is the REAL session restoration method from our
    // AuthController.
    final sessionRestore = authController.restoreSession();

    await Future.wait([
      splashDelay,
      sessionRestore,
    ]);

    if (!mounted) {
      return;
    }

    final status = authController.status.value;

    switch (status) {
      // ══════════════════════════════════════════════════════════
      // USER ALREADY LOGGED IN
      // ══════════════════════════════════════════════════════════
      case AuthStatus.authenticated:
        /*
         * IMPORTANT:
         *
         * We DO NOT ask the user to log in again.
         *
         * The backend session has been successfully restored.
         *
         * For now we go to /home because that route currently
         * exists in AppPages.
         *
         * The next step is replacing /home with our actual
         * role-based gateway:
         *
         * SUPER_ADMIN
         * ADMIN
         * CORE_TEAM
         * MEMBER
         * STUDENT
         *
         * We will NOT change that architecture.
         */
        Get.offNamed(AppRoutes.roleGateway);
        break;

      // ══════════════════════════════════════════════════════════
      // NO VALID SESSION
      // ══════════════════════════════════════════════════════════
      case AuthStatus.unauthenticated:
        /*
         * No access token OR the stored session could not be
         * restored.
         *
         * Therefore the user must authenticate.
         *
         * We NEVER send this user to MEMBER, STUDENT, ADMIN,
         * or any other role screen.
         */
        Get.offNamed(AppRoutes.login);
        break;

      // ══════════════════════════════════════════════════════════
      // STILL CHECKING
      // ══════════════════════════════════════════════════════════
      case AuthStatus.checking:
        /*
         * restoreSession() has already completed before this
         * switch, so this state should not normally occur.
         *
         * Do nothing rather than making an incorrect navigation
         * decision.
         */
        break;
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050506),
      body: Stack(
        children: [
          _AmbientBackground(
            animation: _glowController,
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _markScale,
                      child: const _CampusConnectMark(),
                    ),
                    const SizedBox(height: 34),
                    SlideTransition(
                      position: _contentSlide,
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: Column(
                          children: [
                            Text(
                              'CAMPUS CONNECT',
                              style: AppTextStyles.titleLarge(
                                const Color(0xFFF5F5F7),
                              ).copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppConstants.appTagline,
                              style: AppTextStyles.bodyMedium(
                                const Color(0xFF85858F),
                              ).copyWith(
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: FadeTransition(
              opacity: _contentFade,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLine(),
                  const SizedBox(width: 10),
                  const Text(
                    'BUILT FOR BUILDERS',
                    style: TextStyle(
                      color: Color(0xFF55555F),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildLine(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine() {
    return Container(
      width: 24,
      height: 1,
      color: const Color(0xFF292930),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// CAMPUS CONNECT LOGO
// ═════════════════════════════════════════════════════════════════

class _CampusConnectMark extends StatelessWidget {
  const _CampusConnectMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF292932),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 45,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.08),
            blurRadius: 70,
          ),
        ],
      ),
      child: const CustomPaint(
        painter: _CampusMarkPainter(),
      ),
    );
  }
}

class _CampusMarkPainter extends CustomPainter {
  const _CampusMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    // Left bracket
    final purplePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final leftBracket = Path()
      ..moveTo(center.dx - 18, center.dy - 22)
      ..lineTo(center.dx - 30, center.dy)
      ..lineTo(center.dx - 18, center.dy + 22);

    canvas.drawPath(leftBracket, purplePaint);

    // Right bracket
    final tealPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rightBracket = Path()
      ..moveTo(center.dx + 18, center.dy - 22)
      ..lineTo(center.dx + 30, center.dy)
      ..lineTo(center.dx + 18, center.dy + 22);

    canvas.drawPath(rightBracket, tealPaint);

    // Connection
    final connectionPaint = Paint()
      ..color = const Color(0xFFEDEDF2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - 8, center.dy),
      Offset(center.dx + 8, center.dy),
      connectionPaint,
    );

    // Center nodes
    final nodePaint = Paint()..style = PaintingStyle.fill;

    nodePaint.color = AppColors.primary;

    canvas.drawCircle(
      Offset(center.dx - 9, center.dy),
      3.2,
      nodePaint,
    );

    nodePaint.color = AppColors.secondary;

    canvas.drawCircle(
      Offset(center.dx + 9, center.dy),
      3.2,
      nodePaint,
    );

    // Top / bottom nodes
    nodePaint.color = const Color(0xFFEDEDF2);

    canvas.drawCircle(
      Offset(center.dx, center.dy - 34),
      2.3,
      nodePaint,
    );

    canvas.drawCircle(
      Offset(center.dx, center.dy + 34),
      2.3,
      nodePaint,
    );

    final connectorPaint = Paint()
      ..color = const Color(0xFF363640)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    canvas.drawLine(
      Offset(center.dx, center.dy - 31),
      Offset(center.dx, center.dy - 23),
      connectorPaint,
    );

    canvas.drawLine(
      Offset(center.dx, center.dy + 23),
      Offset(center.dx, center.dy + 31),
      connectorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ═════════════════════════════════════════════════════════════════
// AMBIENT BACKGROUND
// ═════════════════════════════════════════════════════════════════

class _AmbientBackground extends StatelessWidget {
  final Animation<double> animation;

  const _AmbientBackground({
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;

        return IgnorePointer(
          child: Stack(
            children: [
              Positioned(
                top: -180 + (value * 18),
                right: -160,
                child: _Glow(
                  size: 420,
                  color: AppColors.primary,
                  opacity: 0.055,
                ),
              ),
              Positioned(
                bottom: -220 - (value * 18),
                left: -180,
                child: _Glow(
                  size: 460,
                  color: AppColors.secondary,
                  opacity: 0.035,
                ),
              ),
              Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.025),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Glow({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}
