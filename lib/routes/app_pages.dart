import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/role_gateway.dart';
import '../features/core_team/core_team_dashboard.dart';
import '../features/member/member_dashboard.dart';
import '../features/splash/splash_screen.dart';
import '../features/student/student_dashboard.dart';
import '../features/super_admin/controllers/super_admin_controller.dart';
import '../features/super_admin/super_admin_dashboard.dart';
import '../features/events/event_list_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();
  static const String initial = AppRoutes.splash;

  static final List<GetPage> routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),
    GetPage(name: AppRoutes.roleGateway, page: () => const RoleGateway()),
    GetPage(
      name: AppRoutes.superAdmin,
      page: () => const SuperAdminDashboard(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SuperAdminController>(() => SuperAdminController(apiClient: Get.find<ApiClient>()));
      }),
    ),
    GetPage(name: AppRoutes.admin, page: () => const AdminDashboard()),
    GetPage(name: AppRoutes.coreTeam, page: () => const CoreTeamDashboard()),
    GetPage(name: AppRoutes.member, page: () => const MemberDashboard()),
    GetPage(name: AppRoutes.student, page: () => const StudentDashboard()),
    GetPage(
      name: AppRoutes.events,
      page: () => EventListScreen(role: Get.find<AuthController>().role ?? 'STUDENT'),
    ),
  ];
}
