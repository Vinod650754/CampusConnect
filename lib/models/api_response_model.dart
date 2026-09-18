/// Mirrors the backend's standard response envelope:
/// { success, message, data, pagination, timestamp }
class ApiResponseModel<T> {
  final bool success;
  final String message;
  final T? data;
  final PaginationModel? pagination;
  final DateTime timestamp;

  ApiResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.pagination,
    required this.timestamp,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponseModel<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'] as T?,
      pagination: json['pagination'] != null ? PaginationModel.fromJson(json['pagination']) : null,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationModel({required this.page, required this.limit, required this.total, required this.totalPages});

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}
