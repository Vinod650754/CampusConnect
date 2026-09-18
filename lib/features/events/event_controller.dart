import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../repositories/event_repository.dart';
import '../../repositories/attendance_repository.dart';
import '../auth/auth_controller.dart';
import 'event_model.dart';

class EventController extends GetxController {
  final EventRepository _repository;
  EventController({EventRepository? repository}) : _repository = repository ?? EventRepository(Get.find<ApiClient>());

  final RxList<EventModel> events = <EventModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<EventStatus?> statusFilter = Rx<EventStatus?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxnString errorMessage = RxnString();
  final RxInt total = 0.obs;
  final RxInt page = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxMap<String, String> ownAttendanceLabels = <String, String>{}.obs;

  List<EventModel> get filteredEvents => events.where((event) {
        final q = searchQuery.value.trim().toLowerCase();
        final matchesQuery = q.isEmpty || event.title.toLowerCase().contains(q) || event.description.toLowerCase().contains(q) || (event.venue ?? '').toLowerCase().contains(q);
        final matchesStatus = statusFilter.value == null || event.status == statusFilter.value;
        return matchesQuery && matchesStatus;
      }).toList();

  int get upcomingCount => events.where((e) => e.status == EventStatus.upcoming).length;
  int get ongoingCount => events.where((e) => e.status == EventStatus.ongoing).length;
  int get completedCount => events.where((e) => e.status == EventStatus.completed).length;

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _repository.list(search: searchQuery.value, page: 1, limit: 50);
      events.assignAll(result.events);
      page.value = result.page;
      totalPages.value = result.totalPages;
      total.value = result.total;
      await loadOwnAttendanceLabels();
    } on Exception catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOwnAttendanceLabels() async {
    final role = Get.find<AuthController>().role;
    if (role == 'ADMIN' || role == 'SUPER_ADMIN') {
      ownAttendanceLabels.clear();
      return;
    }
    if (!Get.isRegistered<AttendanceRepository>()) {
      Get.put(AttendanceRepository(Get.find<ApiClient>()));
    }
    final repository = Get.find<AttendanceRepository>();
    final targets = events.where((event) => event.status != EventStatus.upcoming).toList();
    if (targets.isEmpty) {
      ownAttendanceLabels.clear();
      return;
    }
    final results = await Future.wait(targets.map((event) async {
      try {
        final result = await repository.own(event.id);
        return MapEntry(event.id, result.label);
      } catch (_) {
        return MapEntry(event.id, 'Not marked');
      }
    }));
    ownAttendanceLabels.assignAll(Map.fromEntries(results));
  }

  Future<void> refreshEvents() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    try {
      await loadEvents();
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<EventModel?> loadEvent(String id) async {
    try {
      final event = await _repository.getById(id);
      final index = events.indexWhere((e) => e.id == id);
      if (index >= 0) events[index] = event; else events.add(event);
      return event;
    } on Exception catch (e) {
      errorMessage.value = e.toString();
      return null;
    }
  }

  void setSearch(String value) {
    searchQuery.value = value;
    loadEvents();
  }

  void setStatusFilter(EventStatus? status) => statusFilter.value = status;
  void clearFilters() { searchQuery.value = ''; statusFilter.value = null; loadEvents(); }

  Future<bool> addEvent(EventModel draft) async {
    try {
      await _repository.create(
        title: draft.title,
        description: draft.description,
        bannerUrl: draft.bannerUrl,
        venue: draft.venue,
        isOnline: draft.isOnline,
        meetingLink: draft.meetingLink,
        startAt: draft.startAt,
        endAt: draft.endAt,
        registrationDeadline: draft.registrationDeadline,
        capacity: draft.capacity,
      );
      await loadEvents();
      return true;
    } on Exception catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> updateEvent(EventModel updated) async {
    try {
      final event = await _repository.update(
        updated.id,
        title: updated.title,
        description: updated.description,
        bannerUrl: updated.bannerUrl,
        venue: updated.venue,
        isOnline: updated.isOnline,
        meetingLink: updated.meetingLink,
        startAt: updated.startAt,
        endAt: updated.endAt,
        registrationDeadline: updated.registrationDeadline,
        capacity: updated.capacity,
        isPublished: updated.isPublished,
      );
      await loadEvents();
      return true;
    } on Exception catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      await _repository.delete(eventId);
      await loadEvents();
      return true;
    } on Exception catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> publishEvent(String eventId) async {
    try {
      final event = await _repository.publish(eventId);
      await loadEvents();
      return true;
    } on Exception catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<EventAttendanceQr?> attendanceQr(String eventId) async {
    try {
      return await _repository.getAttendanceQr(eventId);
    } on Exception catch (e) {
      errorMessage.value = e.toString();
      return null;
    }
  }
}
