import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../features/notifications/notification_model.dart';

class NotificationPage {
  final List<NotificationModel> notifications;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  const NotificationPage({required this.notifications, required this.page, required this.limit, required this.total, required this.totalPages});
}

class NotificationRepository {
  final ApiClient _api;
  NotificationRepository(this._api);

  Future<NotificationPage> list({bool unreadOnly = false, int page = 1, int limit = 50}) async {
    final response = await _api.get(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'limit': limit, 'unreadOnly': unreadOnly},
    );
    final data = response.data['data'];
    final list = data is List
        ? data.whereType<Map>().map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e))).toList()
        : <NotificationModel>[];
    final p = Map<String, dynamic>.from(response.data['pagination'] as Map? ?? const {});
    return NotificationPage(
      notifications: list,
      page: (p['page'] as num?)?.toInt() ?? page,
      limit: (p['limit'] as num?)?.toInt() ?? limit,
      total: (p['total'] as num?)?.toInt() ?? list.length,
      totalPages: (p['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Future<void> markRead(String id) async => _api.patch(ApiEndpoints.notificationRead(id));
  Future<void> markAllRead() async => _api.patch(ApiEndpoints.notificationsReadAll);
}
