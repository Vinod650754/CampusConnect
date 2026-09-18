import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../features/registrations/registration_model.dart';

class RegistrationPage {
  final List<RegistrationModel> registrations;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  const RegistrationPage({
    required this.registrations,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });
}

class RegistrationRepository {
  final ApiClient _api;
  RegistrationRepository(this._api);

  Future<RegistrationPage> my({int page = 1, int limit = 20}) async {
    final response = await _api.get(
      ApiEndpoints.registrationsMy,
      queryParameters: {'page': page, 'limit': limit},
    );
    return _page(response.data['data'], response.data['pagination'], page, limit);
  }

  Future<RegistrationModel> register(String eventId) async {
    final response = await _api.post(ApiEndpoints.registerForEvent(eventId));
    return RegistrationModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<RegistrationModel> cancel(String registrationId) async {
    final response = await _api.patch(ApiEndpoints.cancelRegistration(registrationId));
    return RegistrationModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<RegistrationPage> forEvent(
    String eventId, {
    String? search,
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _api.get(
      ApiEndpoints.eventRegistrations(eventId),
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null) 'status': status,
      },
    );
    return _page(response.data['data'], response.data['pagination'], page, limit);
  }

  Future<RegistrationModel> updateStatus(String id, String status) async {
    final response = await _api.patch(
      ApiEndpoints.updateRegistrationStatus(id),
      data: {'status': status},
    );
    return RegistrationModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  RegistrationPage _page(dynamic data, dynamic pagination, int page, int limit) {
    final list = data is List
        ? data.whereType<Map>().map((e) => RegistrationModel.fromJson(Map<String, dynamic>.from(e))).toList()
        : <RegistrationModel>[];
    final p = Map<String, dynamic>.from(pagination as Map? ?? const {});
    return RegistrationPage(
      registrations: list,
      page: (p['page'] as num?)?.toInt() ?? page,
      limit: (p['limit'] as num?)?.toInt() ?? limit,
      total: (p['total'] as num?)?.toInt() ?? list.length,
      totalPages: (p['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
