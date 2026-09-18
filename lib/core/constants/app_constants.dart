/// Global, non-environment-specific constants used across the app.
class AppConstants {
  AppConstants._();

  static const String appName = 'Campus Connect';
  static const String appTagline = 'Where builders belong.';

  // Pagination defaults
  static const int defaultPageSize = 20;

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 400);

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
