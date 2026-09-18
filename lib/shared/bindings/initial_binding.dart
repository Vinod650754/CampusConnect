import 'package:get/get.dart';

import '../../features/auth/auth_controller.dart';
import '../../core/network/api_client.dart';
import '../../services/connectivity_service.dart';
import '../../services/secure_storage_service.dart';
import '../../services/local_storage_service.dart';
import '../../repositories/auth_repository.dart';

/// Registers every app-wide singleton before the app renders.
///
/// App-wide services and authentication state live here.
/// Feature-specific controllers should remain scoped to their
/// respective feature/routes.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ═══════════════════════════════════════════════════════════════
    // SERVICES
    // ═══════════════════════════════════════════════════════════════

    Get.put(
      SecureStorageService(),
      permanent: true,
    );

    Get.put(
      ConnectivityService(),
      permanent: true,
    );

    // ═══════════════════════════════════════════════════════════════
    // API CLIENT
    // ═══════════════════════════════════════════════════════════════

    Get.put(
      ApiClient(
        secureStorage: Get.find<SecureStorageService>(),
      ),
      permanent: true,
    );

    // ═══════════════════════════════════════════════════════════════
    // REPOSITORIES
    // ═══════════════════════════════════════════════════════════════

    Get.put(
      AuthRepository(
        apiClient: Get.find<ApiClient>(),
        secureStorage: Get.find<SecureStorageService>(),
      ),
      permanent: true,
    );

    // ═══════════════════════════════════════════════════════════════
    // AUTH CONTROLLER
    // ═══════════════════════════════════════════════════════════════

    Get.put(
      AuthController(
        authRepository: Get.find<AuthRepository>(),
        secureStorage: Get.find<SecureStorageService>(),
      ),
      permanent: true,
    );
  }

  /// Initializes asynchronous app-wide dependencies before runApp().
  static Future<void> initAsync() async {
    final localStorage = await LocalStorageService.init();

    Get.put(
      localStorage,
      permanent: true,
    );
  }
}
