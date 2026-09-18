import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../features/attendance/attendance_model.dart';

class AttendancePage {
  final List<AttendanceModel> records;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  const AttendancePage({required this.records, required this.page, required this.limit, required this.total, required this.totalPages});
}

class AttendanceRepository {
  final ApiClient _api;
  AttendanceRepository(this._api);

  Future<AttendanceScanResult> scan(String qrToken) async {
    final response = await _api.post(
      ApiEndpoints.attendanceScan,
      data: {'qrToken': qrToken},
    );
    return AttendanceScanResult.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }

  Future<AttendancePage> event(
    String eventId, {
    String? search,
    String? status,
    int page = 1,
    int limit = 100,
  }) async {
    final response = await _api.get(
      ApiEndpoints.eventAttendance(eventId),
      queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null) 'status': status,
      },
    );
    final data = response.data['data'];
    final list = data is List
        ? data.whereType<Map>().map((e) => AttendanceModel.fromJson(Map<String, dynamic>.from(e))).toList()
        : <AttendanceModel>[];
    final p = Map<String, dynamic>.from(response.data['pagination'] as Map? ?? const {});
    return AttendancePage(
      records: list,
      page: (p['page'] as num?)?.toInt() ?? page,
      limit: (p['limit'] as num?)?.toInt() ?? limit,
      total: (p['total'] as num?)?.toInt() ?? list.length,
      totalPages: (p['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  Future<AttendanceOwnResult> own(String eventId) async {
    final response = await _api.get(ApiEndpoints.ownAttendance(eventId));
    return AttendanceOwnResult.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }

  Future<AttendanceModel> update(String attendanceId, String status) async {
    final response = await _api.patch(
      ApiEndpoints.updateAttendance(attendanceId),
      data: {'status': status},
    );
    return AttendanceModel.fromJson(Map<String, dynamic>.from(response.data['data'] as Map));
  }
}

class AttendanceScanResult {
  final String id;
  final String eventId;
  final String eventTitle;
  final String status;
  final DateTime? checkInAt;
  final String qrType;
  const AttendanceScanResult({required this.id, required this.eventId, required this.eventTitle, required this.status, this.checkInAt, required this.qrType});
  factory AttendanceScanResult.fromJson(Map<String, dynamic> json) => AttendanceScanResult(
    id: json['id'] as String? ?? '',
    eventId: json['eventId'] as String? ?? '',
    eventTitle: json['eventTitle'] as String? ?? '',
    status: json['status'] as String? ?? 'PRESENT',
    checkInAt: DateTime.tryParse(json['checkInAt']?.toString() ?? ''),
    qrType: json['qrType'] as String? ?? '',
  );
}

class AttendanceOwnResult {
  final Map<String, dynamic> event;
  final bool registered;
  final AttendanceModel? attendance;
  final String label;
  const AttendanceOwnResult({required this.event, required this.registered, required this.attendance, required this.label});
  factory AttendanceOwnResult.fromJson(Map<String, dynamic> json) {
    final raw = json['attendance'];
    return AttendanceOwnResult(
      event: Map<String, dynamic>.from(json['event'] as Map? ?? const {}),
      registered: json['registered'] as bool? ?? false,
      attendance: raw is Map ? AttendanceModel.fromJson(Map<String, dynamic>.from(raw)) : null,
      label: json['label'] as String? ?? 'Not marked',
    );
  }
}
