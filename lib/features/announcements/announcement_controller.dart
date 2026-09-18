import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../repositories/announcement_repository.dart';
import 'announcement_model.dart';

class AnnouncementController extends GetxController {
  final AnnouncementRepository _repository;
  AnnouncementController({AnnouncementRepository? repository}) : _repository = repository ?? AnnouncementRepository(Get.find<ApiClient>());
  final RxList<AnnouncementModel> announcements = <AnnouncementModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxnString errorMessage = RxnString();
  bool loadAdmin = false;

  List<AnnouncementModel> get filteredAnnouncements {
    final q = searchQuery.value.trim().toLowerCase();
    return announcements.where((a) => q.isEmpty || a.title.toLowerCase().contains(q) || a.content.toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() { super.onInit(); loadAnnouncements(); }

  Future<void> loadAnnouncements({bool? admin}) async {
    if (admin != null) loadAdmin = admin;
    isLoading.value = true;
    try { final result = await _repository.list(admin: loadAdmin); announcements.assignAll(result.announcements); }
    on Exception catch (e) { errorMessage.value = e.toString(); }
    finally { isLoading.value = false; }
  }

  void setSearch(String value) => searchQuery.value = value;

  Future<bool> addAnnouncement(AnnouncementModel draft) async {
    try {
      await _repository.create(title: draft.title, content: draft.content, targetRoles: draft.backendTargetRoles, isPinned: draft.isPinned, isPublished: draft.isPublished);
      await loadAnnouncements();
      return true;
    } on Exception catch (e) { errorMessage.value = e.toString(); return false; }
  }

  Future<bool> updateAnnouncement(AnnouncementModel draft) async {
    try {
      await _repository.update(draft.id, title: draft.title, content: draft.content, targetRoles: draft.backendTargetRoles, isPinned: draft.isPinned, isPublished: draft.isPublished);
      await loadAnnouncements();
      return true;
    } on Exception catch (e) { errorMessage.value = e.toString(); return false; }
  }

  Future<bool> deleteAnnouncement(String id) async {
    try { await _repository.delete(id); await loadAnnouncements(); return true; }
    on Exception catch (e) { errorMessage.value = e.toString(); return false; }
  }
}
