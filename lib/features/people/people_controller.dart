import 'dart:async';

import 'package:get/get.dart';

import '../../core/errors/exceptions.dart';
import 'people_models.dart';
import 'people_repository.dart';

/// Controller for the SUPER_ADMIN People module.
///
/// Handles:
/// - user listing
/// - search
/// - role filtering
/// - pagination
/// - refresh
/// - user details
/// - role assignment/removal
/// - user deletion
///
/// UI never talks directly to the API.
class PeopleController extends GetxController {
  final PeopleRepository _repository;

  PeopleController({
    required PeopleRepository repository,
  }) : _repository = repository;

  // ═══════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════

  final RxList<PeopleUser> users = <PeopleUser>[].obs;

  final Rxn<PeopleUser> selectedUser = Rxn<PeopleUser>();

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingDetails = false.obs;
  final RxBool isManagingRole = false.obs;
  final RxBool isDeletingUser = false.obs;

  final RxnString errorMessage = RxnString();

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalUsers = 0.obs;

  final RxString searchQuery = ''.obs;
  final RxnString selectedRole = RxnString();

  Timer? _searchDebounce;

  // ═══════════════════════════════════════════════════════════════
  // CONSTANTS
  // ═══════════════════════════════════════════════════════════════

  static const int pageSize = 20;

  static const List<String> availableRoles = <String>[
    'SUPER_ADMIN',
    'ADMIN',
    'CORE_TEAM',
    'MEMBER',
    'STUDENT',
  ];

  // ═══════════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════════

  bool get hasUsers => users.isNotEmpty;

  bool get isEmpty =>
      !isLoading.value && users.isEmpty && errorMessage.value == null;

  bool get hasMorePages => currentPage.value < totalPages.value;

  bool get hasSearch => searchQuery.value.trim().isNotEmpty;

  bool get hasRoleFilter => selectedRole.value != null;

  bool get hasActiveFilters => hasSearch || hasRoleFilter;

  // ═══════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════
  // LOAD USERS
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadUsers({
    bool showLoader = true,
  }) async {
    if (showLoader) {
      isLoading.value = true;
    }

    errorMessage.value = null;
    currentPage.value = 1;

    try {
      final response = await _repository.getUsers(
        search: _normalizedSearch,
        role: selectedRole.value,
        page: 1,
        limit: pageSize,
      );

      users.assignAll(response.users);

      currentPage.value = response.pagination.page;
      totalPages.value = response.pagination.totalPages;
      totalUsers.value = response.pagination.total;
    } on Exception catch (error) {
      errorMessage.value = _messageFromException(error);
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════════

  Future<void> refreshUsers() async {
    if (isRefreshing.value) {
      return;
    }

    isRefreshing.value = true;
    errorMessage.value = null;

    try {
      final response = await _repository.getUsers(
        search: _normalizedSearch,
        role: selectedRole.value,
        page: 1,
        limit: pageSize,
      );

      users.assignAll(response.users);

      currentPage.value = response.pagination.page;
      totalPages.value = response.pagination.totalPages;
      totalUsers.value = response.pagination.total;
    } on Exception catch (error) {
      errorMessage.value = _messageFromException(error);
    } finally {
      isRefreshing.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // PAGINATION
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMorePages) {
      return;
    }

    isLoadingMore.value = true;

    try {
      final nextPage = currentPage.value + 1;

      final response = await _repository.getUsers(
        search: _normalizedSearch,
        role: selectedRole.value,
        page: nextPage,
        limit: pageSize,
      );

      users.addAll(response.users);

      currentPage.value = response.pagination.page;
      totalPages.value = response.pagination.totalPages;
      totalUsers.value = response.pagination.total;
    } on Exception catch (error) {
      errorMessage.value = _messageFromException(error);
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SEARCH
  // ═══════════════════════════════════════════════════════════════

  void search(String value) {
    searchQuery.value = value;

    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () {
        loadUsers();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ROLE FILTER
  // ═══════════════════════════════════════════════════════════════

  Future<void> setRoleFilter(String? role) async {
    if (role == 'ALL' || role == null || role.isEmpty) {
      selectedRole.value = null;
    } else {
      selectedRole.value = role;
    }

    await loadUsers();
  }

  Future<void> clearFilters() async {
    searchQuery.value = '';
    selectedRole.value = null;

    _searchDebounce?.cancel();

    await loadUsers();
  }

  // ═══════════════════════════════════════════════════════════════
  // USER DETAILS
  // ═══════════════════════════════════════════════════════════════

  Future<PeopleUser?> loadUserDetails(String userId) async {
    isLoadingDetails.value = true;
    errorMessage.value = null;

    try {
      final user = await _repository.getUser(userId);

      selectedUser.value = user;

      // Keep the list synchronized with the latest details.
      final index = users.indexWhere(
        (item) => item.id == user.id,
      );

      if (index != -1) {
        users[index] = user;
      }

      return user;
    } on Exception catch (error) {
      errorMessage.value = _messageFromException(error);
      return null;
    } finally {
      isLoadingDetails.value = false;
    }
  }

  void clearSelectedUser() {
    selectedUser.value = null;
  }

  // ═══════════════════════════════════════════════════════════════
  // ASSIGN / REPLACE ROLE
  // ═══════════════════════════════════════════════════════════════

  Future<bool> addRole({
    required String userId,
    required String role,
  }) async {
    if (!availableRoles.contains(role)) {
      errorMessage.value = 'Invalid role.';
      return false;
    }

    if (isManagingRole.value) {
      return false;
    }

    isManagingRole.value = true;
    errorMessage.value = null;

    try {
      await _repository.assignRole(
        userId: userId,
        role: role,
      );

      // Fetch the complete user again so the local state reflects
      // the backend's actual role assignments.
      await loadUserDetails(userId);

      return true;
    } on Exception catch (error) {
      errorMessage.value = _messageFromException(error);
      return false;
    } finally {
      isManagingRole.value = false;
    }
  }

  Future<bool> removeRole({required String userId, required String role}) async {
    if (role == 'STUDENT') {
      errorMessage.value = 'STUDENT is the base role and cannot be removed.';
      return false;
    }
    return addRole(userId: userId, role: 'STUDENT');
  }

  // ═══════════════════════════════════════════════════════════════
  // DELETE USER
  // ═══════════════════════════════════════════════════════════════

  Future<bool> deleteUser(String userId) async {
    if (isDeletingUser.value) {
      return false;
    }

    isDeletingUser.value = true;
    errorMessage.value = null;

    try {
      await _repository.deleteUser(userId);

      users.removeWhere(
        (user) => user.id == userId,
      );

      if (selectedUser.value?.id == userId) {
        selectedUser.value = null;
      }

      if (totalUsers.value > 0) {
        totalUsers.value--;
      }

      return true;
    } on Exception catch (error) {
      errorMessage.value = _messageFromException(error);
      return false;
    } finally {
      isDeletingUser.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ═══════════════════════════════════════════════════════════════

  void clearError() {
    errorMessage.value = null;
  }

  String? get _normalizedSearch {
    final value = searchQuery.value.trim();

    if (value.isEmpty) {
      return null;
    }

    return value;
  }

  String _messageFromException(Exception error) {
    if (error is NetworkException) {
      return error.message;
    }

    if (error is UnauthorizedException) {
      return error.message;
    }

    if (error is ValidationException) {
      return error.message;
    }

    if (error is ServerException) {
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }
}
