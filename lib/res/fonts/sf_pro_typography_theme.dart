import 'package:flutter/material.dart';
import 'fonts.dart';
import 'fonts.g.dart';

/// Pre-defined heading text styles
abstract class SFProHeadings {
  static const TextStyle h1 = SFProTextStyles.heading1Bold;
  static const TextStyle h1SemiBold = SFProTextStyles.heading1SemiBold;
  static const TextStyle h1Medium = SFProTextStyles.heading1Medium;
  static const TextStyle h1Regular = SFProTextStyles.heading1Regular;

  static const TextStyle h2 = SFProTextStyles.heading2Bold;
  static const TextStyle h2SemiBold = SFProTextStyles.heading2SemiBold;
  static const TextStyle h2Medium = SFProTextStyles.heading2Medium;
  static const TextStyle h2Regular = SFProTextStyles.heading2Regular;

  static const TextStyle h3 = SFProTextStyles.largeBold;
  static const TextStyle h3SemiBold = SFProTextStyles.largeSemiBold;
  static const TextStyle h3Medium = SFProTextStyles.largeMedium;
  static const TextStyle h3Regular = SFProTextStyles.largeRegular;
}

/// Pre-defined body text styles
abstract class SFProBody {
  static const TextStyle largeRegular = SFProTextStyles.bodyLargeRegular;
  static const TextStyle largeMedium = SFProTextStyles.bodyLargeMedium;
  static const TextStyle largeSemiBold = SFProTextStyles.bodyLargeSemiBold;
  static const TextStyle largeBold = SFProTextStyles.bodyLargeBold;

  static const TextStyle regular = SFProTextStyles.bodyRegular;
  static const TextStyle medium = SFProTextStyles.bodyMedium;
  static const TextStyle semiBold = SFProTextStyles.bodySemiBold;
  static const TextStyle bold = SFProTextStyles.bodyBold;

  static const TextStyle smallRegular = SFProTextStyles.bodySmallRegular;
  static const TextStyle smallMedium = SFProTextStyles.bodySmallMedium;
  static const TextStyle smallSemiBold = SFProTextStyles.bodySmallSemiBold;
  static const TextStyle smallBold = SFProTextStyles.bodySmallBold;

  static const TextStyle mediumRegular = SFProTextStyles.bodyMediumRegular;
  static const TextStyle mediumMedium = SFProTextStyles.bodyMediumMedium;
  static const TextStyle mediumSemiBold = SFProTextStyles.bodyMediumSemiBold;
  static const TextStyle mediumBold = SFProTextStyles.bodyMediumBold;
}

/// Pre-defined caption/label text styles
abstract class SFProCaptions {
  static const TextStyle regular = SFProTextStyles.captionRegular;
  static const TextStyle medium = SFProTextStyles.captionMedium;
  static const TextStyle semiBold = SFProTextStyles.captionSemiBold;
  static const TextStyle bold = SFProTextStyles.captionBold;

  static const TextStyle extraSmallRegular = SFProTextStyles.extraSmallRegular;
  static const TextStyle extraSmallMedium = SFProTextStyles.extraSmallMedium;
  static const TextStyle extraSmallSemiBold =
      SFProTextStyles.extraSmallSemiBold;
  static const TextStyle extraSmallBold = SFProTextStyles.extraSmallBold;
}

/// Pre-defined display text styles
abstract class SFProDisplay {
  static const TextStyle bold = SFProTextStyles.displayBold;
  static const TextStyle semiBold = SFProTextStyles.displaySemiBold;
  static const TextStyle medium = SFProTextStyles.displayMedium;
  static const TextStyle regular = SFProTextStyles.displayRegular;
}

/// SF Pro Typography Theme Provider
/// Integrates SF Pro fonts with Flutter's Material Design system
class SFProTypographyTheme {
  /// Generate Material TextTheme using SF Pro font family
  /// This replaces the default Material font with SF Pro throughout the app
  static TextTheme createTextTheme() {
    return TextTheme(
      // Display Large (40px) - Main app title
      displayLarge: SFProTextStyles.displayBold,

      // Display Medium (34px equivalent) - Not used directly, using display variations
      displayMedium: SFProTextStyles.displaySemiBold,

      // Display Small (28px equivalent)
      displaySmall: SFProTextStyles.heading1Bold,

      // Headline Large (32px equivalent) - Page titles
      headlineLarge: SFProTextStyles.heading1Bold,

      // Headline Medium (28px equivalent) - Section titles
      headlineMedium: SFProTextStyles.heading2Bold,

      // Headline Small (24px equivalent) - Card titles
      headlineSmall: SFProTextStyles.heading2Regular,

      // Title Large (22px equivalent)
      titleLarge: SFProTextStyles.largeBold,

      // Title Medium (16px equivalent)
      titleMedium: SFProTextStyles.bodySemiBold,

      // Title Small (14px equivalent)
      titleSmall: SFProTextStyles.bodySmallSemiBold,

      // Body Large (18px) - Long form text
      bodyLarge: SFProTextStyles.bodyLargeRegular,

      // Body Medium (16px) - Standard body text
      bodyMedium: SFProTextStyles.bodyRegular,

      // Body Small (14px) - Secondary text
      bodySmall: SFProTextStyles.bodySmallRegular,

      // Label Large (14px) - Labels
      labelLarge: SFProTextStyles.bodySmallMedium,

      // Label Medium (12px) - Medium labels
      labelMedium: SFProTextStyles.captionMedium,

      // Label Small (11px equivalent) - Small labels
      labelSmall: SFProTextStyles.captionRegular,
    );
  }

  /// Get a text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Get a text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Get a text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Get a text style with custom height (line height)
  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }

  /// Get a text style with custom letter spacing
  static TextStyle withLetterSpacing(TextStyle style, double spacing) {
    return style.copyWith(letterSpacing: spacing);
  }

  /// Create custom text style with multiple properties
  static TextStyle custom({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.4,
    double letterSpacing = 0,
    Color? color,
    TextDecoration? decoration,
    String fontFamily = FontFamily.sfProText,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      decoration: decoration,
    );
  }
}

/// Convenient alias for common typography access
typedef Typography = SFProTypographyTheme;

/// Extension method for easy theme access
extension TextThemeExtension on ThemeData {
  /// Get SF Pro typography theme
  static TextTheme get sfProTheme => SFProTypographyTheme.createTextTheme();
}
