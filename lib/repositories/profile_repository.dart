import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class ProfileRepository {
  final ApiClient _api;
  ProfileRepository(this._api);

  Future<UserModel> get() async {
    final response = await _api.get(ApiEndpoints.profileMe);
    return UserModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<UserModel> update({String? fullName, String? phone, String? email, String? avatarUrl, String? bio}) async {
    final response = await _api.patch(
      ApiEndpoints.profileMe,
      data: {
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (bio != null) 'bio': bio,
      },
    );
    return UserModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await _api.patch(
      ApiEndpoints.profilePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
