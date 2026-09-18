import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../features/gallery/gallery_model.dart';

class GalleryPage {
  final List<GalleryImageModel> images;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  const GalleryPage({required this.images, required this.page, required this.limit, required this.total, required this.totalPages});
}

class GalleryRepository {
  final ApiClient _api;
  GalleryRepository(this._api);

  Future<GalleryPage> list({String? eventId, int page = 1, int limit = 50}) async {
    final response = await _api.get(
      ApiEndpoints.gallery,
      queryParameters: {'page': page, 'limit': limit, if (eventId != null) 'eventId': eventId},
    );
    final data = response.data['data'];
    final list = data is List
        ? data.whereType<Map>().map((e) => GalleryImageModel.fromJson(Map<String, dynamic>.from(e))).toList()
        : <GalleryImageModel>[];
    final p = Map<String, dynamic>.from(response.data['pagination'] as Map? ?? const {});
    return GalleryPage(
      images: list,
      page: (p['page'] as num?)?.toInt() ?? page,
      limit: (p['limit'] as num?)?.toInt() ?? limit,
      total: (p['total'] as num?)?.toInt() ?? list.length,
      totalPages: (p['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Future<GalleryImageModel> add({required String imageUrl, String? caption, String? eventId}) async {
    final response = await _api.post(
      ApiEndpoints.gallery,
      data: {
        'imageUrl': imageUrl,
        if (caption != null && caption.trim().isNotEmpty) 'caption': caption.trim(),
        if (eventId != null && eventId.trim().isNotEmpty) 'eventId': eventId.trim(),
      },
    );
    return GalleryImageModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<GalleryImageModel> update(String id, {String? caption, String? eventId}) async {
    final response = await _api.patch(
      ApiEndpoints.galleryById(id),
      data: {
        if (caption != null) 'caption': caption,
        if (eventId != null) 'eventId': eventId,
      },
    );
    return GalleryImageModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }

  Future<void> delete(String id) async => _api.delete(ApiEndpoints.galleryById(id));
}
