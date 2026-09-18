import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

/// Converts a raw [DioException] into one of the app's typed exceptions so
/// the repository layer never has to deal with Dio-specific types.
class DioExceptionMapper {
  static Exception map(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('The connection timed out. Please try again.');

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _mapStatusCode(error);

      case DioExceptionType.cancel:
        return const ServerException('Request was cancelled');

      default:
        return ServerException(error.message ?? 'An unexpected error occurred');
    }
  }

  static Exception _mapStatusCode(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final message = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : 'Something went wrong';

    switch (statusCode) {
      case 400:
        final errors = data is Map && data['errors'] is List
            ? {
                for (final e in (data['errors'] as List))
                  if (e is Map && e['field'] != null) e['field'].toString(): e['message'].toString(),
              }
            : null;
        return ValidationException(message, fieldErrors: errors);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return UnauthorizedException(message);
      case 404:
        return ServerException(message, statusCode: 404);
      default:
        return ServerException(message, statusCode: statusCode);
    }
  }
}
