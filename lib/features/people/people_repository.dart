import '../../core/constants/api_endpoints.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import 'people_models.dart';

class PeopleRepository {
  final ApiClient _apiClient;
  PeopleRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<PeopleListResponse> getUsers({String? search, String? role, int page = 1, int limit = 20}) async {
    final response = await _apiClient.get(ApiEndpoints.users, queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (role != null && role.trim().isNotEmpty) 'role': role.trim(),
    });
    final data = response.data['data'] as List? ?? const [];
    final pagination = response.data['pagination'] as Map? ?? const {};
    return PeopleListResponse.fromJson({'users': data, 'pagination': pagination});
  }

  Future<PeopleUser> getUser(String userId) async {
    final response = await _apiClient.get('${ApiEndpoints.users}/$userId');
    final data = response.data['data'];
    if (data is! Map) throw ServerException('User details were not returned by the server.');
    return PeopleUser.fromJson(Map<String, dynamic>.from(data));
  }

  Future<UserRoleAssignment> assignRole({required String userId, required String role}) async {
    final response = await _apiClient.put('${ApiEndpoints.users}/$userId/role', data: {'role': role});
    final data = response.data['data'];
    if (data is! Map) throw ServerException('Role assignment response was empty.');
    return UserRoleAssignment.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> addRole({required String userId, required String role}) async { await assignRole(userId: userId, role: role); }
  Future<void> deleteUser(String userId) async { await _apiClient.delete('${ApiEndpoints.users}/$userId'); }
}
