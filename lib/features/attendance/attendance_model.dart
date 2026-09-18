import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent, late, excused }

class AttendanceModel extends Equatable {
  final String id;
  final String eventId;
  final String eventTitle;
  final String userId;
  final String userName;
  final String userEmail;
  final AttendanceStatus status;
  final DateTime? checkInAt;
  final String? markedBy;

  const AttendanceModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.status,
    this.checkInAt,
    this.markedBy,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final event = json['event'] is Map ? Map<String, dynamic>.from(json['event'] as Map) : const <String, dynamic>{};
    final user = json['user'] is Map ? Map<String, dynamic>.from(json['user'] as Map) : const <String, dynamic>{};
    final raw = (json['status'] ?? 'ABSENT').toString().toUpperCase();
    return AttendanceModel(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String? ?? event['id'] as String? ?? '',
      eventTitle: event['title'] as String? ?? '',
      userId: json['userId'] as String? ?? user['id'] as String? ?? '',
      userName: user['fullName'] as String? ?? '',
      userEmail: user['email'] as String? ?? '',
      status: switch (raw) {
        'PRESENT' => AttendanceStatus.present,
        'LATE' => AttendanceStatus.late,
        'EXCUSED' => AttendanceStatus.excused,
        _ => AttendanceStatus.absent,
      },
      checkInAt: DateTime.tryParse(json['checkInAt']?.toString() ?? ''),
      markedBy: json['markedBy'] as String?,
    );
  }

  AttendanceModel copyWith({AttendanceStatus? status, DateTime? checkInAt}) => AttendanceModel(id: id, eventId: eventId, eventTitle: eventTitle, userId: userId, userName: userName, userEmail: userEmail, status: status ?? this.status, checkInAt: checkInAt ?? this.checkInAt, markedBy: markedBy);
  String get statusLabel => status.name[0].toUpperCase() + status.name.substring(1);
  @override List<Object?> get props => [id, eventId, eventTitle, userId, userName, userEmail, status, checkInAt, markedBy];
}
