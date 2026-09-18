import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../features/certificates/certificate_model.dart';

class CertificateRepository {
  final ApiClient _api;
  CertificateRepository(this._api);

  Future<List<CertificateModel>> my() async {
    final response = await _api.get(ApiEndpoints.certificatesMy);
    final data = response.data['data'];
    return data is List
        ? data.whereType<Map>().map((e) => CertificateModel.fromJson(Map<String, dynamic>.from(e))).toList()
        : <CertificateModel>[];
  }

  Future<CertificateModel> issue({required String userId, String? eventId, required String title, String? certificateUrl}) async {
    final response = await _api.post(
      ApiEndpoints.certificates,
      data: {
        'userId': userId,
        if (eventId != null && eventId.trim().isNotEmpty) 'eventId': eventId.trim(),
        'title': title,
        if (certificateUrl != null && certificateUrl.trim().isNotEmpty) 'certificateUrl': certificateUrl.trim(),
      },
    );
    return CertificateModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<CertificateModel> revoke(String id) async {
    final response = await _api.patch(ApiEndpoints.certificateRevoke(id));
    return CertificateModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<Map<String, dynamic>> verify(String hash) async {
    final response = await _api.get(ApiEndpoints.certificateVerify(hash));
    return Map<String, dynamic>.from(response.data['data'] as Map);
  }
}
