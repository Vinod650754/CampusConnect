import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../features/events/event_model.dart';

class EventPage {
  final List<EventModel> events;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const EventPage({
    required this.events,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });
}

class EventRepository {
  final ApiClient _api;

  EventRepository(this._api);

  Future<EventPage> list({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get(
      ApiEndpoints.events,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final raw = response.data['data'];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => EventModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <EventModel>[];

    final p = Map<String, dynamic>.from(
      response.data['pagination'] as Map? ?? const {},
    );

    return EventPage(
      events: list,
      page: (p['page'] as num?)?.toInt() ?? page,
      limit: (p['limit'] as num?)?.toInt() ?? limit,
      total: (p['total'] as num?)?.toInt() ?? list.length,
      totalPages: (p['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Future<EventModel> getById(String id) async {
    final response = await _api.get(ApiEndpoints.eventById(id));
    return EventModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }

  Future<EventModel> create({
    required String title,
    String? description,
    String? bannerUrl,
    String? venue,
    required bool isOnline,
    String? meetingLink,
    required DateTime startAt,
    required DateTime endAt,
    DateTime? registrationDeadline,
    int? capacity,
  }) async {
    final response = await _api.post(
      ApiEndpoints.events,
      data: {
        'title': title,
        if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
        if (bannerUrl != null && bannerUrl.trim().isNotEmpty) 'bannerUrl': bannerUrl.trim(),
        if (venue != null && venue.trim().isNotEmpty) 'venue': venue.trim(),
        'isOnline': isOnline,
        if (meetingLink != null && meetingLink.trim().isNotEmpty) 'meetingLink': meetingLink.trim(),
        'startAt': startAt.toUtc().toIso8601String(),
        'endAt': endAt.toUtc().toIso8601String(),
        if (registrationDeadline != null) 'registrationDeadline': registrationDeadline.toUtc().toIso8601String(),
        if (capacity != null) 'capacity': capacity,
      },
    );
    return EventModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }

  Future<EventModel> update(
    String id, {
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
  }) async {
    final response = await _api.patch(
      ApiEndpoints.eventById(id),
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (bannerUrl != null) 'bannerUrl': bannerUrl,
        if (venue != null) 'venue': venue,
        if (isOnline != null) 'isOnline': isOnline,
        if (meetingLink != null) 'meetingLink': meetingLink,
        if (startAt != null) 'startAt': startAt.toUtc().toIso8601String(),
        if (endAt != null) 'endAt': endAt.toUtc().toIso8601String(),
        if (registrationDeadline != null) 'registrationDeadline': registrationDeadline.toUtc().toIso8601String(),
        if (capacity != null) 'capacity': capacity,
        if (isPublished != null) 'isPublished': isPublished,
      },
    );
    return EventModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }

  Future<EventModel> publish(String id) async {
    final response = await _api.post(ApiEndpoints.publishEvent(id));
    return EventModel.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }

  Future<void> delete(String id) async {
    await _api.delete(ApiEndpoints.eventById(id));
  }

  Future<EventAttendanceQr> getAttendanceQr(String id) async {
    final response = await _api.get(ApiEndpoints.eventAttendanceQr(id));
    return EventAttendanceQr.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }
}

class EventAttendanceQr {
  final String eventId;
  final String? staffToken;
  final String? studentToken;
  final DateTime? generatedAt;

  const EventAttendanceQr({
    required this.eventId,
    this.staffToken,
    this.studentToken,
    this.generatedAt,
  });

  factory EventAttendanceQr.fromJson(Map<String, dynamic> json) {
    final qr = json['attendanceQr'];
    final map = qr is Map ? Map<String, dynamic>.from(qr) : const <String, dynamic>{};
    final staff = map['staff'];
    final student = map['student'];
    return EventAttendanceQr(
      eventId: json['eventId'] as String? ?? '',
      staffToken: json['staffQrToken'] as String? ?? (staff is Map ? staff['token'] as String? : null),
      studentToken: json['studentQrToken'] as String? ?? (student is Map ? student['token'] as String? : null),
      generatedAt: DateTime.tryParse(json['generatedAt']?.toString() ?? map['generatedAt']?.toString() ?? ''),
    );
  }
}
