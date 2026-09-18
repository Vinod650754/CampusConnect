import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../repositories/gallery_repository.dart';
import 'gallery_model.dart';

class GalleryController extends GetxController {
  final GalleryRepository _repository;
  GalleryController({GalleryRepository? repository}) : _repository = repository ?? GalleryRepository(Get.find<ApiClient>());
  final RxList<GalleryImageModel> images = <GalleryImageModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxnString selectedEventId = RxnString();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  List<GalleryImageModel> get filteredImages {
    final q = searchQuery.value.trim().toLowerCase();
    return images.where((i) {
      final matchQ = q.isEmpty || (i.caption ?? '').toLowerCase().contains(q) || (i.eventTitle ?? '').toLowerCase().contains(q) || i.uploaderName.toLowerCase().contains(q);
      final matchEvent = selectedEventId.value == null || i.eventId == selectedEventId.value;
      return matchQ && matchEvent;
    }).toList();
  }
  List<String> get eventNames => images.map((e) => e.eventTitle).whereType<String>().toSet().toList();

  @override void onInit() { super.onInit(); loadGallery(); }
  Future<void> loadGallery() async { isLoading.value = true; try { final r = await _repository.list(eventId: selectedEventId.value); images.assignAll(r.images); } on Exception catch (e) { errorMessage.value = e.toString(); } finally { isLoading.value = false; } }
  void setSearch(String v) => searchQuery.value = v;
  void setEventFilter(String? id) { selectedEventId.value = id; loadGallery(); }
  Future<bool> addImage(GalleryImageModel draft) async { try { final x = await _repository.add(imageUrl: draft.imageUrl, caption: draft.caption, eventId: draft.eventId); images.insert(0, x); return true; } on Exception catch (e) { errorMessage.value = e.toString(); return false; } }
  Future<bool> updateImage(GalleryImageModel draft) async { try { final x = await _repository.update(draft.id, caption: draft.caption, eventId: draft.eventId); final i = images.indexWhere((e) => e.id == draft.id); if (i >= 0) images[i] = x; return true; } on Exception catch (e) { errorMessage.value = e.toString(); return false; } }
  Future<bool> deleteImage(String id) async { try { await _repository.delete(id); images.removeWhere((e) => e.id == id); return true; } on Exception catch (e) { errorMessage.value = e.toString(); return false; } }
}
