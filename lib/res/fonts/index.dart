/// Fonts module - Export all font-related classes
///
/// Usage:
/// ```dart
/// import 'res/fonts/index.dart';
///
/// // Use R accessor
/// Text('Hello', style: R.styles.heading1())
///
/// // Use font families
/// Text('Text', style: TextStyle(fontFamily: R.fonts.sfPro))
///
/// // Use pre-defined styles
/// Text('Text', style: SFProHeadings.h1)
/// ```

export 'fonts.dart';
export 'fonts.g.dart';
export 'font_resources.dart';
export 'sf_pro_typography_theme.dart';
