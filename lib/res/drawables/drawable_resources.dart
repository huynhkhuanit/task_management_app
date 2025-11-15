/// Strongly-typed accessor for drawable resources (images).
/// Usage:
/// ```dart
/// Image.asset(R.drawables.onboarding1);
/// ```
class DrawableResources {
  const DrawableResources();

  static const String _basePath = 'assets/images';

  /// Helper to create the asset path.
  String _asset(String fileName) => '$_basePath/$fileName';

  /// ============ ONBOARDING IMAGES ============

  /// Onboarding screen - Step 1 image
  String get onboarding1 => _asset('onboarding_1.png');

  /// Alias for onboarding1
  String get onboarding_1 => onboarding1;

  /// Onboarding screen - Step 2 image
  String get onboarding2 => _asset('onboarding_2.png');

  /// Alias for onboarding2
  String get onboarding_2 => onboarding2;

  /// Onboarding screen - Step 3 image
  String get onboarding3 => _asset('onboarding_3.png');

  /// Alias for onboarding3
  String get onboarding_3 => onboarding3;

  /// ============ LOGO ============

  /// App logo
  String get logo => _asset('logo.png');

  /// ============ ADD MORE IMAGES BELOW ============
  // String get imageName => _asset('image_name.png');
}

/// Optional direct accessor without the R helper.
const Drawables = DrawableResources();
