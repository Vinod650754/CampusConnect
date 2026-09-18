/// Centralized asset paths so features never hardcode `assets/...` strings.
class AssetPaths {
  AssetPaths._();

  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _lottie = 'assets/lottie';

  static const String logo = '$_images/logo.png';
  static const String logoMark = '$_images/logo_mark.png';
  static const String placeholderAvatar = '$_images/placeholder_avatar.png';

  static const String loadingAnimation = '$_lottie/loading.json';
  static const String emptyStateAnimation = '$_lottie/empty_state.json';
  static const String successAnimation = '$_lottie/success.json';
  static const String errorAnimation = '$_lottie/error.json';

  static const String appIcon = '$_icons/app_icon.png';
}
