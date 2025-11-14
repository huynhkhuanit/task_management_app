import 'package:flutter/material.dart';
import '../drawables/drawable_resources.dart';

/// Global Resource accessor - Alias for cleaner syntax
/// Usage: R.fonts.sfPro, R.fonts.sfProDisplay, R.styles.heading1()
class R {
  /// Font resources accessor
  static const fonts = _FontsAccessor();

  /// Font style generators
  static const styles = _StylesAccessor();

  /// Font weight options
  static const weights = _WeightsAccessor();

  /// Drawable resources accessor
  static const drawables = DrawableResources();
}

/// Internal accessor for fonts
class _FontsAccessor {
  const _FontsAccessor();

  /// SF Pro Text Font Family - 'SFProText'
  /// Used for: Body text, standard text content
  String get sfPro => 'SFProText';

  /// SF Pro Display Font Family - 'SFProDisplay'
  /// Used for: Headings, display text, titles
  String get sfProDisplay => 'SFProDisplay';

  /// SF Pro Rounded Font Family - 'SFProRounded'
  /// Used for: Modern, friendly UI elements
  String get sfProRounded => 'SFProRounded';

  /// Default font family (SF Pro Text)
  String get defaultFont => 'SFProText';
}

/// Internal accessor for styles
class _StylesAccessor {
  const _StylesAccessor();

  /// Create heading 1 style (28px)
  TextStyle heading1({
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'SFProDisplay',
      fontSize: 28,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.4,
    );
  }

  /// Create heading 2 style (24px)
  TextStyle heading2({
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'SFProDisplay',
      fontSize: 24,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.4,
    );
  }

  /// Create body text style
  TextStyle body({
    FontWeight weight = FontWeight.w400,
    Color? color,
    double size = 16,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'SFProText',
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.5,
    );
  }

  /// Create caption/label style
  TextStyle caption({
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'SFProText',
      fontSize: 12,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.2,
    );
  }

  /// Create button text style
  TextStyle button({
    FontWeight weight = FontWeight.w600,
    Color? color,
    double size = 16,
    double letterSpacing = 0.5,
  }) {
    return TextStyle(
      fontFamily: 'SFProText',
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.5,
    );
  }

  /// Create display text style (40px)
  TextStyle display({
    FontWeight weight = FontWeight.w700,
    Color? color,
    double size = 40,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'SFProDisplay',
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.2,
    );
  }
}

/// Internal accessor for font weights
class _WeightsAccessor {
  const _WeightsAccessor();

  /// Ultra light weight (100)
  FontWeight get ultraLight => FontWeight.w100;

  /// Thin weight (200)
  FontWeight get thin => FontWeight.w200;

  /// Light weight (300)
  FontWeight get light => FontWeight.w300;

  /// Regular weight (400)
  FontWeight get regular => FontWeight.w400;

  /// Medium weight (500)
  FontWeight get medium => FontWeight.w500;

  /// Semi-bold weight (600)
  FontWeight get semiBold => FontWeight.w600;

  /// Bold weight (700)
  FontWeight get bold => FontWeight.w700;

  /// Extra-bold weight (800)
  FontWeight get extraBold => FontWeight.w800;

  /// Black weight (900)
  FontWeight get black => FontWeight.w900;
}
