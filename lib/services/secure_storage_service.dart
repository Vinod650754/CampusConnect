import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/storage_keys.dart';

/// Thin wrapper around [FlutterSecureStorage] for sensitive data (tokens).
/// Never store tokens in SharedPreferences — this is why the two storage
/// services are kept separate.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  Future<void> saveAccessToken(String token) => _storage.write(key: StorageKeys.accessToken, value: token);

  Future<String?> getAccessToken() => _storage.read(key: StorageKeys.accessToken);

  Future<void> saveRefreshToken(String token) => _storage.write(key: StorageKeys.refreshToken, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: StorageKeys.refreshToken);

  Future<void> clearTokens() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
  }

  Future<void> clearAll() => _storage.deleteAll();
}
