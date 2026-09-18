import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../repositories/notification_repository.dart';
import 'notification_model.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository;
  NotificationController({NotificationRepository? repository}) : _repository = repository ?? NotificationRepository(Get.find<ApiClient>());
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  int get unreadCount => notifications.where((n) => !n.isRead).length;
  @override void onInit() { super.onInit(); load(); }
  Future<void> load({bool unreadOnly = false}) async {
    isLoading.value = true;
    try { final result = await _repository.list(unreadOnly: unreadOnly); notifications.assignAll(result.notifications); }
    finally { isLoading.value = false; }
  }
  Future<void> markRead(String id) async { await _repository.markRead(id); final i = notifications.indexWhere((n) => n.id == id); if (i >= 0) notifications[i] = notifications[i].copyWith(isRead: true); }
  Future<void> markAllRead() async { await _repository.markAllRead(); notifications.value = notifications.map((n) => n.copyWith(isRead: true)).toList(); }
}
