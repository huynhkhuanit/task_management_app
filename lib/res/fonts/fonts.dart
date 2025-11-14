/// Font weight constants for SF Pro font family
/// Provides standardized font weights across the application
abstract class FontWeights {
  /// Ultra light weight (100)
  static const double ultraLight = 100;

  /// Thin weight (200)
  static const double thin = 200;

  /// Light weight (300)
  static const double light = 300;

  /// Normal/Regular weight (400)
  static const double normal = 400;

  /// Medium weight (500)
  static const double medium = 500;

  /// Semi-bold weight (600)
  static const double semiBold = 600;

  /// Bold weight (700)
  static const double bold = 700;

  /// Extra-bold weight (800)
  static const double extraBold = 800;

  /// Black weight (900)
  static const double black = 900;
}

/// Font size constants for SF Pro font family
/// Provides standardized text sizes across the application
abstract class FontSizes {
  /// Extra small size (10)
  static const double extraSmall = 10;

  /// Small size (12)
  static const double small = 12;

  /// Small-medium size (13)
  static const double smallMedium = 13;

  /// Medium size (14)
  static const double medium = 14;

  /// Medium-large size (15)
  static const double mediumLarge = 15;

  /// Large size (16)
  static const double large = 16;

  /// Large-extra size (18)
  static const double largeExtra = 18;

  /// Extra large size (20)
  static const double extraLarge = 20;

  /// Heading 2 size (24)
  static const double heading2 = 24;

  /// Heading 1 size (28)
  static const double heading1 = 28;

  /// Display size (32)
  static const double display = 32;

  /// Large display size (40)
  static const double largeDisplay = 40;
}

/// Line height constants for optimal readability
abstract class LineHeights {
  /// Tight line height (1.0)
  static const double tight = 1.0;

  /// Compact line height (1.2)
  static const double compact = 1.2;

  /// Normal line height (1.4)
  static const double normal = 1.4;

  /// Relaxed line height (1.5)
  static const double relaxed = 1.5;

  /// Loose line height (1.6)
  static const double loose = 1.6;

  /// Extra loose line height (1.8)
  static const double extraLoose = 1.8;
}

/// Letter spacing constants for typography styling
abstract class LetterSpacings {
  /// No letter spacing (0)
  static const double none = 0;

  /// Extra tight spacing (0.25)
  static const double extraTight = 0.25;

  /// Tight spacing (0.5)
  static const double tight = 0.5;

  /// Normal spacing (0.75)
  static const double normal = 0.75;

  /// Wide spacing (1.0)
  static const double wide = 1.0;

  /// Extra wide spacing (1.5)
  static const double extraWide = 1.5;

  /// Ultra wide spacing (2.0)
  static const double ultraWide = 2.0;
}

/// Font family constant for SF Pro
abstract class FontFamily {
  /// SF Pro Display font family (macOS/iOS standard)
  static const String sfProDisplay = 'SFProDisplay';

  /// SF Pro Text font family (standard text)
  static const String sfProText = 'SFProText';

  /// SF Pro Rounded font family
  static const String sfProRounded = 'SFProRounded';
}
