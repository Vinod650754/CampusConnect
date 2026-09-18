import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../features/announcements/announcement_model.dart';

class AnnouncementPage {
  final List<AnnouncementModel> announcements;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  const AnnouncementPage({required this.announcements, required this.page, required this.limit, required this.total, required this.totalPages});
}

class AnnouncementRepository {
  final ApiClient _api;
  AnnouncementRepository(this._api);

  Future<AnnouncementPage> list({bool admin = false, int page = 1, int limit = 20}) async {
    final response = await _api.get(
      admin ? ApiEndpoints.adminAnnouncements : ApiEndpoints.announcements,
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data['data'];
    final list = data is List
        ? data.whereType<Map>().map((e) => AnnouncementModel.fromJson(Map<String, dynamic>.from(e))).toList()
        : <AnnouncementModel>[];
    final p = Map<String, dynamic>.from(response.data['pagination'] as Map? ?? const {});
    return AnnouncementPage(
      announcements: list,
      page: (p['page'] as num?)?.toInt() ?? page,
      limit: (p['limit'] as num?)?.toInt() ?? limit,
      total: (p['total'] as num?)?.toInt() ?? list.length,
      totalPages: (p['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Future<AnnouncementModel> getById(String id) async {
    final response = await _api.get(ApiEndpoints.announcementById(id));
    return AnnouncementModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<AnnouncementModel> create({required String title, required String content, required List<String> targetRoles, required bool isPinned, required bool isPublished}) async {
    final response = await _api.post(
      ApiEndpoints.announcements,
      data: {
        'title': title,
        'content': content,
        'targetRoles': targetRoles,
        'isPinned': isPinned,
        'isPublished': isPublished,
      },
    );
    final payload = Map<String, dynamic>.from(response.data['data'] as Map);
    return AnnouncementModel.fromJson(Map<String, dynamic>.from(payload['announcement'] as Map));
  }

  Future<AnnouncementModel> update(String id, {String? title, String? content, List<String>? targetRoles, bool? isPinned, bool? isPublished}) async {
    final response = await _api.patch(
      ApiEndpoints.announcementById(id),
      data: {
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (targetRoles != null) 'targetRoles': targetRoles,
        if (isPinned != null) 'isPinned': isPinned,
        if (isPublished != null) 'isPublished': isPublished,
      },
    );
    return AnnouncementModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<void> delete(String id) async {
    await _api.delete(ApiEndpoints.announcementById(id));
  }
}
