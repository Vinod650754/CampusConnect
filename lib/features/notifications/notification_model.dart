import 'package:equatable/equatable.dart';

enum NotificationType { info, success, warning, error, event, certificate, announcement, attendance, system }

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const NotificationModel({required this.id, required this.title, required this.message, required this.type, required this.isRead, required this.createdAt, this.metadata});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final raw = (json['type'] ?? 'INFO').toString().toUpperCase();
    return NotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: switch (raw) {
        'SUCCESS' => NotificationType.success,
        'WARNING' => NotificationType.warning,
        'ERROR' => NotificationType.error,
        'EVENT' => NotificationType.event,
        'CERTIFICATE' => NotificationType.certificate,
        'ANNOUNCEMENT' => NotificationType.announcement,
        'ATTENDANCE' => NotificationType.attendance,
        'SYSTEM' => NotificationType.system,
        _ => NotificationType.info,
      },
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata'] as Map) : null,
    );
  }
  NotificationModel copyWith({bool? isRead}) => NotificationModel(id: id, title: title, message: message, type: type, isRead: isRead ?? this.isRead, createdAt: createdAt, metadata: metadata);
  @override List<Object?> get props => [id, title, message, type, isRead, createdAt, metadata];
}
