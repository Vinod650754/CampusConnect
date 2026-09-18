import 'package:dio/dio.dart';
import '../../config/env_config.dart';
import '../../services/secure_storage_service.dart';
import '../constants/api_endpoints.dart';

/// Attaches the access token to every request and transparently refreshes
/// it on a 401 response, retrying the original request exactly once.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Dio _refreshDio;
  bool _isRefreshing = false;

  AuthInterceptor(this._secureStorage)
      : _refreshDio = Dio(BaseOptions(baseUrl: EnvConfig.baseUrl));

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRetry = err.requestOptions.extra['retried'] == true;

    if (isUnauthorized && !isRetry && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken == null) {
          throw Exception('No refresh token available');
        }

        final response = await _refreshDio.post(
          ApiEndpoints.refreshToken,
          data: {'refreshToken': refreshToken},
        );

        final newAccess = response.data['data']['accessToken'] as String;
        final newRefresh = response.data['data']['refreshToken'] as String;

        await _secureStorage.saveAccessToken(newAccess);
        await _secureStorage.saveRefreshToken(newRefresh);

        final retryRequest = err.requestOptions;
        retryRequest.headers['Authorization'] = 'Bearer $newAccess';
        retryRequest.extra['retried'] = true;

        final cloneReq = await _refreshDio.fetch(retryRequest);
        _isRefreshing = false;
        return handler.resolve(cloneReq);
      } catch (_) {
        _isRefreshing = false;
        await _secureStorage.clearTokens();
        // Feature code (e.g. a root-level auth controller/listener) should
        // observe token clearance and route the user back to login.
      }
    }

    handler.next(err);
  }
}
