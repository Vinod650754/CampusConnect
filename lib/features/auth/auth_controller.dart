import 'package:get/get.dart';

import '../../core/errors/failures.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';
import '../../services/secure_storage_service.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;

  AuthController({
    required AuthRepository authRepository,
    required SecureStorageService secureStorage,
  })  : _authRepository = authRepository,
        _secureStorage = secureStorage;

  final Rx<AuthStatus> status = AuthStatus.checking.obs;

  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  final RxBool isChecking = false.obs;

  final RxBool isLoading = false.obs;

  final Rxn<Failure> lastFailure = Rxn<Failure>();

  bool get isLoggedIn => currentUser.value != null;

  UserModel? get user => currentUser.value;

  bool get hasError => lastFailure.value != null;

  String? get role => currentUser.value?.role;

  bool hasRole(String expectedRole) {
    return role == expectedRole;
  }

  bool get isSuperAdmin => hasRole('SUPER_ADMIN');

  bool get isAdmin => hasRole('ADMIN');

  bool get isCoreTeam => hasRole('CORE_TEAM');

  bool get isMember => hasRole('MEMBER');

  bool get isStudent => hasRole('STUDENT');

  bool get hasAdministrativeAccess => isSuperAdmin || isAdmin;

  Future<void> restoreSession() async {
    if (isChecking.value) {
      return;
    }

    isChecking.value = true;
    status.value = AuthStatus.checking;
    lastFailure.value = null;

    try {
      final accessToken = await _secureStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        currentUser.value = null;
        status.value = AuthStatus.unauthenticated;
        return;
      }

      final result = await _authRepository.getProfile();

      result.fold(
        (failure) {
          currentUser.value = null;
          lastFailure.value = failure;
          status.value = AuthStatus.unauthenticated;
        },
        (user) {
          currentUser.value = user;
          lastFailure.value = null;
          status.value = AuthStatus.authenticated;
        },
      );
    } catch (_) {
      currentUser.value = null;
      status.value = AuthStatus.unauthenticated;
    } finally {
      isChecking.value = false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (isLoading.value) {
      return false;
    }

    isLoading.value = true;
    lastFailure.value = null;

    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      return result.fold(
        (failure) {
          currentUser.value = null;
          lastFailure.value = failure;
          status.value = AuthStatus.unauthenticated;

          return false;
        },
        (user) {
          currentUser.value = user;
          lastFailure.value = null;
          status.value = AuthStatus.authenticated;

          return true;
        },
      );
    } catch (_) {
      currentUser.value = null;
      status.value = AuthStatus.unauthenticated;
      Get.offAllNamed(AppRoutes.login);

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? rollNumber,
    String? department,
  }) async {
    if (isLoading.value) {
      return false;
    }

    isLoading.value = true;
    lastFailure.value = null;

    try {
      final result = await _authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
        rollNumber: rollNumber,
        department: department,
      );

      return result.fold(
        (failure) {
          lastFailure.value = failure;
          return false;
        },
        (_) {
          return true;
        },
      );
    } catch (_) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> logout() async {
    if (isLoading.value) {
      return false;
    }

    isLoading.value = true;
    lastFailure.value = null;

    try {
      final result = await _authRepository.logout();

      return result.fold(
        (failure) {
          currentUser.value = null;
          status.value = AuthStatus.unauthenticated;
          lastFailure.value = failure;
          Get.offAllNamed(AppRoutes.login);

          return false;
        },
        (_) {
          currentUser.value = null;
          status.value = AuthStatus.unauthenticated;
          lastFailure.value = null;
          Get.offAllNamed(AppRoutes.login);

          return true;
        },
      );
    } catch (_) {
      currentUser.value = null;
      status.value = AuthStatus.unauthenticated;

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    lastFailure.value = null;
  }
}

enum AuthStatus {
  checking,
  authenticated,
  unauthenticated,
}
