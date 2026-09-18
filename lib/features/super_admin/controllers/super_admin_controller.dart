import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../../../core/errors/failures.dart';
import '../../../core/constants/api_endpoints.dart';
import '../models/user_overview_model.dart';

class SuperAdminController extends GetxController {
  final ApiClient _apiClient;

  SuperAdminController({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final Rxn<UserOverviewModel> overview = Rxn<UserOverviewModel>();

  final RxBool isLoading = false.obs;
  final Rxn<Failure> failure = Rxn<Failure>();

  bool get hasData => overview.value != null;

  Future<void> loadOverview() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    failure.value = null;

    try {
      final response = await _apiClient.get(
        ApiEndpoints.userOverview,
      );

      final responseData = response.data['data'];

      if (responseData is! Map<String, dynamic>) {
        throw Exception('Invalid user overview response');
      }

      overview.value = UserOverviewModel.fromJson(responseData);
    } catch (e) {
      // Keep the dashboard usable even if the overview request fails.
      failure.value = const UnknownFailure();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOverview() async {
    await loadOverview();
  }
}
