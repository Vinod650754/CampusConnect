import 'package:equatable/equatable.dart';

class GalleryImageModel extends Equatable {
  final String id;
  final String imageUrl;
  final String? caption;
  final String? eventId;
  final String? eventTitle;
  final String uploadedBy;
  final String uploaderName;
  final DateTime createdAt;

  const GalleryImageModel({required this.id, required this.imageUrl, this.caption, this.eventId, this.eventTitle, required this.uploadedBy, required this.uploaderName, required this.createdAt});

  factory GalleryImageModel.fromJson(Map<String, dynamic> json) {
    final uploader = json['uploader'] is Map ? Map<String, dynamic>.from(json['uploader'] as Map) : const <String, dynamic>{};
    final event = json['event'] is Map ? Map<String, dynamic>.from(json['event'] as Map) : const <String, dynamic>{};
    return GalleryImageModel(
      id: json['id'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      caption: json['caption'] as String?,
      eventId: json['eventId'] as String? ?? event['id'] as String?,
      eventTitle: event['title'] as String?,
      uploadedBy: json['uploadedBy'] as String? ?? uploader['id'] as String? ?? '',
      uploaderName: uploader['fullName'] as String? ?? 'CampusConnect',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
  GalleryImageModel copyWith({String? imageUrl, String? caption, String? eventId, String? eventTitle}) => GalleryImageModel(id: id, imageUrl: imageUrl ?? this.imageUrl, caption: caption ?? this.caption, eventId: eventId ?? this.eventId, eventTitle: eventTitle ?? this.eventTitle, uploadedBy: uploadedBy, uploaderName: uploaderName, createdAt: createdAt);
  @override List<Object?> get props => [id, imageUrl, caption, eventId, eventTitle, uploadedBy, uploaderName, createdAt];
}
