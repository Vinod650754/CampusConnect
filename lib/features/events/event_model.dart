import 'package:equatable/equatable.dart';

enum EventStatus { upcoming, ongoing, completed }

class EventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? bannerUrl;
  final String? venue;
  final bool isOnline;
  final String? meetingLink;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? registrationDeadline;
  final int? capacity;
  final bool isPublished;
  final EventStatus status;
  final int registrationCount;
  final int attendanceCount;
  final String? staffQrToken;
  final String? studentQrToken;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.bannerUrl,
    this.venue,
    required this.isOnline,
    this.meetingLink,
    required this.startAt,
    required this.endAt,
    this.registrationDeadline,
    this.capacity,
    required this.isPublished,
    required this.status,
    this.registrationCount = 0,
    this.attendanceCount = 0,
    this.staffQrToken,
    this.studentQrToken,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] is Map
        ? Map<String, dynamic>.from(json['_count'] as Map)
        : const <String, dynamic>{};
    final qr = json['attendanceQr'] is Map
        ? Map<String, dynamic>.from(json['attendanceQr'] as Map)
        : const <String, dynamic>{};
    final staff = qr['staff'];
    final student = qr['student'];
    final status = (json['status'] ?? 'UPCOMING').toString().toUpperCase();

    return EventModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bannerUrl: json['bannerUrl'] as String?,
      venue: json['venue'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      meetingLink: json['meetingLink'] as String?,
      startAt: DateTime.tryParse(json['startAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      endAt: DateTime.tryParse(json['endAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      registrationDeadline: DateTime.tryParse(json['registrationDeadline']?.toString() ?? ''),
      capacity: (json['capacity'] as num?)?.toInt(),
      isPublished: json['isPublished'] as bool? ?? false,
      status: switch (status) {
        'ONGOING' => EventStatus.ongoing,
        'COMPLETED' => EventStatus.completed,
        _ => EventStatus.upcoming,
      },
      registrationCount: (json['registrationCount'] as num?)?.toInt() ?? (count['registrations'] as num?)?.toInt() ?? 0,
      attendanceCount: (json['attendanceCount'] as num?)?.toInt() ?? (count['attendance'] as num?)?.toInt() ?? 0,
      staffQrToken: json['staffAttendanceQrToken'] as String? ?? (staff is Map ? staff['token'] as String? : null),
      studentQrToken: json['studentAttendanceQrToken'] as String? ?? (student is Map ? student['token'] as String? : null),
    );
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? bannerUrl,
    String? venue,
    bool? isOnline,
    String? meetingLink,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? registrationDeadline,
    int? capacity,
    bool? isPublished,
    EventStatus? status,
    int? registrationCount,
    int? attendanceCount,
    String? staffQrToken,
    String? studentQrToken,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      venue: venue ?? this.venue,
      isOnline: isOnline ?? this.isOnline,
      meetingLink: meetingLink ?? this.meetingLink,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      capacity: capacity ?? this.capacity,
      isPublished: isPublished ?? this.isPublished,
      status: status ?? this.status,
      registrationCount: registrationCount ?? this.registrationCount,
      attendanceCount: attendanceCount ?? this.attendanceCount,
      staffQrToken: staffQrToken ?? this.staffQrToken,
      studentQrToken: studentQrToken ?? this.studentQrToken,
    );
  }

  int get remainingSeats => capacity == null ? 0 : (capacity! - registrationCount).clamp(0, capacity!);

  String get statusLabel => status.name.toUpperCase();

  @override
  List<Object?> get props => [id, title, description, bannerUrl, venue, isOnline, meetingLink, startAt, endAt, registrationDeadline, capacity, isPublished, status, registrationCount, attendanceCount, staffQrToken, studentQrToken];
}
