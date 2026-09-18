import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../config/env_config.dart';
import '../../services/connectivity_service.dart';
import '../../services/secure_storage_service.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'auth_interceptor.dart';
import 'dio_exception_mapper.dart';

/// Single, shared HTTP client for the whole app. Every repository should
/// go through this rather than instantiating Dio directly, so that base
/// URL, timeouts, auth headers, refresh logic, and logging stay consistent.
class ApiClient {
  late final Dio dio;
  final ConnectivityService _connectivity;

  ApiClient({
    required SecureStorageService secureStorage,
    ConnectivityService? connectivity,
  }) : _connectivity = connectivity ?? ConnectivityService() {
    dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(AuthInterceptor(secureStorage));

    if (EnvConfig.isDevelopment) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          compact: true,
        ),
      );
    }
  }

  Future<void> _assertConnected() async {
    final connected = await _connectivity.isConnected;
    if (!connected) {
      throw const NetworkException();
    }
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    await _assertConnected();
    try {
      return await dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw DioExceptionMapper.map(e);
    }
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    await _assertConnected();
    try {
      return await dio.post<T>(path, data: data);
    } on DioException catch (e) {
      throw DioExceptionMapper.map(e);
    }
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    await _assertConnected();
    try {
      return await dio.put<T>(path, data: data);
    } on DioException catch (e) {
      throw DioExceptionMapper.map(e);
    }
  }

  Future<Response<T>> patch<T>(String path, {dynamic data}) async {
    await _assertConnected();
    try {
      return await dio.patch<T>(path, data: data);
    } on DioException catch (e) {
      throw DioExceptionMapper.map(e);
    }
  }

  Future<Response<T>> delete<T>(String path, {dynamic data}) async {
    await _assertConnected();
    try {
      return await dio.delete<T>(path, data: data);
    } on DioException catch (e) {
      throw DioExceptionMapper.map(e);
    }
  }
}
