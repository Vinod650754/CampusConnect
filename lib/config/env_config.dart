import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment configuration.
///
/// --dart-define values take precedence for release/CI builds.
/// .env remains available for local development.
class EnvConfig {
  EnvConfig._();

  static String get baseUrl =>
      const String.fromEnvironment('BASE_URL').isNotEmpty
          ? const String.fromEnvironment('BASE_URL')
          : (dotenv.env['BASE_URL'] ??
              'https://campus-connect-backend-lln0.onrender.com/api/v1');

  static String get environment =>
      const String.fromEnvironment('ENVIRONMENT').isNotEmpty
          ? const String.fromEnvironment('ENVIRONMENT')
          : (dotenv.env['ENVIRONMENT'] ?? 'development');

  static bool get isProduction => environment == 'production';

  static bool get isDevelopment => environment == 'development';
}
