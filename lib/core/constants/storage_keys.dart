/// Keys used for secure storage / shared preferences. Keeping them in one
/// place avoids typo-driven bugs across features.
class StorageKeys {
  StorageKeys._();

  // Secure storage (sensitive)
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';

  // Shared preferences (non-sensitive)
  static const String isFirstLaunch = 'is_first_launch';
  static const String themeMode = 'theme_mode';
  static const String cachedUser = 'cached_user';
  static const String languageCode = 'language_code';
}
