import 'package:dartz/dartz.dart' show Either, Left, Right;

import '../core/constants/api_endpoints.dart';
import '../core/errors/exceptions.dart';
import '../core/errors/failures.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import '../services/secure_storage_service.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AuthRepository({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  Future<Either<Failure, UserModel>> register({
    required String fullName,
    required String email,
    required String password,
    String? rollNumber,
    String? department,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          if (rollNumber != null && rollNumber.trim().isNotEmpty)
            'rollNumber': rollNumber.trim(),
          if (department != null && department.trim().isNotEmpty)
            'department': department.trim(),
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;

      return Right(
        UserModel.fromJson(data),
      );
    } on Exception catch (e) {
      return Left(
        _toFailure(e),
      );
    }
  }

  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;

      await _secureStorage.saveAccessToken(
        data['accessToken'] as String,
      );

      await _secureStorage.saveRefreshToken(
        data['refreshToken'] as String,
      );

      final userData = data['user'] as Map<String, dynamic>;

      return Right(
        UserModel.fromJson(userData),
      );
    } on Exception catch (e) {
      return Left(
        _toFailure(e),
      );
    }
  }

  Future<Either<Failure, UserModel>> getProfile() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.profile,
      );

      final data = response.data['data'] as Map<String, dynamic>;

      return Right(
        UserModel.fromJson(data),
      );
    } on Exception catch (e) {
      return Left(
        _toFailure(e),
      );
    }
  }

  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiClient.post(
          ApiEndpoints.logout,
          data: {
            'refreshToken': refreshToken,
          },
        );
      }

      await _secureStorage.clearTokens();

      return const Right(null);
    } on Exception catch (e) {
      await _secureStorage.clearTokens();

      return Left(
        _toFailure(e),
      );
    }
  }

  Failure _toFailure(
    Exception e,
  ) {
    if (e is NetworkException) {
      return NetworkFailure(
        e.message,
      );
    }

    if (e is UnauthorizedException) {
      return UnauthorizedFailure(
        e.message,
      );
    }

    if (e is ValidationException) {
      return ValidationFailure(
        e.message,
        fieldErrors: e.fieldErrors,
      );
    }

    if (e is ServerException) {
      return ServerFailure(
        e.message,
        statusCode: e.statusCode,
      );
    }

    return const UnknownFailure();
  }
}
