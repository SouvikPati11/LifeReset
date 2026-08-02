/// Typed references to bundled asset paths.
///
/// Keeping asset paths in one place avoids magic strings scattered across the
/// UI and makes renaming assets a single-edit operation.
class AppAssets {
  const AppAssets._();

  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';

  static const String logo = '$_images/logo.png';
  static const String splashBackground = '$_images/splash_background.png';
  static const String appIcon = '$_icons/app_icon.png';
}
