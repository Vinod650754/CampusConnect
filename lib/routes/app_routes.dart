/// Central registry of route names.
///
/// Keep all application routes here so navigation never depends
/// on hard-coded strings scattered throughout the application.
abstract class AppRoutes {
  AppRoutes._();

  // ═══════════════════════════════════════════════════════════════
  // AUTHENTICATION
  // ═══════════════════════════════════════════════════════════════

  static const String splash = '/splash';

  static const String onboarding = '/onboarding';

  static const String login = '/login';

  static const String register = '/register';

  static const String forgotPassword = '/forgot-password';

  // ═══════════════════════════════════════════════════════════════
  // AUTHENTICATED ENTRY
  // ═══════════════════════════════════════════════════════════════

  /// Receives an authenticated user and sends them to the
  /// workspace belonging to their backend role.
  static const String roleGateway = '/role-gateway';

  // ═══════════════════════════════════════════════════════════════
  // ROLE WORKSPACES
  // ═══════════════════════════════════════════════════════════════

  /// SUPER_ADMIN
  static const String superAdmin = '/super-admin';

  /// ADMIN
  static const String admin = '/admin';

  /// CORE_TEAM
  static const String coreTeam = '/core-team';

  /// MEMBER
  static const String member = '/member';

  /// STUDENT
  static const String student = '/student';

  // ═══════════════════════════════════════════════════════════════
  // COMMON
  // ═══════════════════════════════════════════════════════════════

  static const String home = '/home';

  static const String profile = '/profile';

  // ================================================================
// EVENTS
// ================================================================

  static const String events = '/events';

  static const String createEvent = '/events/create';
}
