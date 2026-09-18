import 'package:equatable/equatable.dart';

enum RegistrationStatus { pending, confirmed, waitlisted, cancelled, attended }

class RegistrationModel extends Equatable {
  final String id;
  final String eventId;
  final String eventTitle;
  final DateTime eventStartAt;
  final DateTime eventEndAt;
  final RegistrationStatus status;
  final DateTime registeredAt;
  final String userId;
  final String userName;
  final String userEmail;

  const RegistrationModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventStartAt,
    required this.eventEndAt,
    required this.status,
    required this.registeredAt,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    final event = json['event'] is Map ? Map<String, dynamic>.from(json['event'] as Map) : const <String, dynamic>{};
    final user = json['user'] is Map ? Map<String, dynamic>.from(json['user'] as Map) : const <String, dynamic>{};
    final rawStatus = (json['status'] ?? 'PENDING').toString().toUpperCase();
    return RegistrationModel(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String? ?? event['id'] as String? ?? '',
      eventTitle: event['title'] as String? ?? json['eventTitle'] as String? ?? '',
      eventStartAt: DateTime.tryParse(event['startAt']?.toString() ?? '') ?? DateTime.tryParse(json['eventStartAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      eventEndAt: DateTime.tryParse(event['endAt']?.toString() ?? '') ?? DateTime.tryParse(json['eventEndAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      status: switch (rawStatus) {
        'CONFIRMED' => RegistrationStatus.confirmed,
        'WAITLISTED' => RegistrationStatus.waitlisted,
        'CANCELLED' => RegistrationStatus.cancelled,
        'ATTENDED' => RegistrationStatus.attended,
        _ => RegistrationStatus.pending,
      },
      registeredAt: DateTime.tryParse(json['registeredAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      userId: json['userId'] as String? ?? user['id'] as String? ?? '',
      userName: user['fullName'] as String? ?? json['userName'] as String? ?? '',
      userEmail: user['email'] as String? ?? json['userEmail'] as String? ?? '',
    );
  }

  RegistrationModel copyWith({RegistrationStatus? status}) => RegistrationModel(id: id, eventId: eventId, eventTitle: eventTitle, eventStartAt: eventStartAt, eventEndAt: eventEndAt, status: status ?? this.status, registeredAt: registeredAt, userId: userId, userName: userName, userEmail: userEmail);
  String get statusLabel => status.name[0].toUpperCase() + status.name.substring(1);
  @override List<Object?> get props => [id, eventId, eventTitle, eventStartAt, eventEndAt, status, registeredAt, userId, userName, userEmail];
}
