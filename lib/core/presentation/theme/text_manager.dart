import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════════
// FONT FAMILIES
// ══════════════════════════════════════════════════════════════════════════════

abstract class AppFonts {
  static const String cairo = 'Cairo';
  static const String inter = 'Inter';
}

// ══════════════════════════════════════════════════════════════════════════════
// TEXT STYLE EXTENSION
// ══════════════════════════════════════════════════════════════════════════════

extension TextStyleX on TextStyle {
  /// Apply regular weight
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  /// Apply medium weight
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Apply semibold weight
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Apply bold weight
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  /// Apply custom color
  TextStyle withColor(Color color) => copyWith(color: color);
}

// ══════════════════════════════════════════════════════════════════════════════
// APP TYPOGRAPHY - Design System Text Styles
// ══════════════════════════════════════════════════════════════════════════════
///
/// Design System Reference:
/// ┌──────────────────────┬──────────┬─────────────┬─────────────────────────┐
/// │ Style                │ Size     │ Line Height │ Font                    │
/// ├──────────────────────┼──────────┼─────────────┼─────────────────────────┤
/// │ Heading M            │ 28px     │ 32px        │ Cairo Bold              │
/// │ Heading S            │ 24px     │ 26px        │ Cairo Bold              │
/// │ Subheading M         │ 20px     │ 24px        │ Cairo Bold              │
/// │ Subheading S         │ 16px     │ 18px        │ Cairo Bold/SemiBold     │
/// │ Body M               │ 16px     │ 20px        │ Inter Regular/Med/Bold  │
/// │ Body S               │ 14px     │ 18px        │ Inter Regular/Med/Bold  │
/// │ Caption M            │ 12px     │ 14px        │ Inter Reg/Semi/Bold     │
/// │ Caption S            │ 12px     │ 14px        │ Inter Medium            │
/// └──────────────────────┴──────────┴─────────────┴─────────────────────────┘

class AppTypography {
  AppTypography._();

  /// Initialize typography (called at app startup)
  static void init() {
    // No-op for now, can be extended for future configuration
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HEADINGS (Cairo Bold)
  // ────────────────────────────────────────────────────────────────────────────

  /// Heading M - 28px, line-height 32px, Cairo Bold
  static TextStyle get headingM => const TextStyle(
    fontFamily: AppFonts.cairo,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 32 / 28,
    letterSpacing: 0,
  );

  /// Heading S - 24px, line-height 26px, Cairo Bold
  static TextStyle get headingS => const TextStyle(
    fontFamily: AppFonts.cairo,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 26 / 24,
    letterSpacing: 0,
  );

  // ────────────────────────────────────────────────────────────────────────────
  // SUBHEADINGS (Cairo)
  // ────────────────────────────────────────────────────────────────────────────

  /// Subheading M - 20px, line-height 24px, Cairo Bold
  static TextStyle get subheadingM => const TextStyle(
    fontFamily: AppFonts.cairo,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 24 / 20,
    letterSpacing: 0,
  );

  /// Subheading S - 16px, line-height 18px, Cairo Bold (default)
  /// Use .semiBold extension for SemiBold variant
  static TextStyle get subheadingS => const TextStyle(
    fontFamily: AppFonts.cairo,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 18 / 16,
    letterSpacing: 0,
  );

  // ────────────────────────────────────────────────────────────────────────────
  // BODY (Inter)
  // ────────────────────────────────────────────────────────────────────────────

  /// Body M - 16px, line-height 20px, Inter Regular (default)
  /// Use .medium or .bold extensions for variants
  static TextStyle get bodyM => const TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 20 / 16,
    letterSpacing: 0,
  );

  /// Body S - 14px, line-height 18px, Inter Regular (default)
  /// Use .medium or .bold extensions for variants
  static TextStyle get bodyS => const TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 18 / 14,
    letterSpacing: 0,
  );

  // ────────────────────────────────────────────────────────────────────────────
  // CAPTIONS (Inter)
  // ────────────────────────────────────────────────────────────────────────────

  /// Caption M - 12px, line-height 14px, Inter Regular (default)
  /// Use .semiBold or .bold extensions for variants
  static TextStyle get captionM => const TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 14 / 12,
    letterSpacing: 0,
  );

  /// Caption M with Cairo Bold - for Arabic captions
  static TextStyle get captionMCairo => const TextStyle(
    fontFamily: AppFonts.cairo,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 14 / 12,
    letterSpacing: 0,
  );

  /// Caption S - 12px, line-height 14px, Inter Medium
  static TextStyle get captionS => const TextStyle(
    fontFamily: AppFonts.inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 14 / 12,
    letterSpacing: 0,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// TEXT MANAGER - Theme Builder (Legacy Support + TextTheme)
// ══════════════════════════════════════════════════════════════════════════════

class TextManager {
  static final TextManager _instance = TextManager._();
  factory TextManager() => _instance;
  TextManager._();

  /// Build TextTheme for light mode
  TextTheme buildLightTextTheme() {
    return TextTheme(
      // Headings -> Display
      displayLarge: AppTypography.headingM,
      displayMedium: AppTypography.headingS,
      displaySmall: AppTypography.subheadingM,
      // Subheadings -> Headlines
      headlineLarge: AppTypography.subheadingM,
      headlineMedium: AppTypography.subheadingS,
      headlineSmall: AppTypography.subheadingS,
      // Body -> Title/Body
      titleLarge: AppTypography.bodyM.bold,
      titleMedium: AppTypography.bodyM.medium,
      titleSmall: AppTypography.bodyM,
      bodyLarge: AppTypography.bodyM,
      bodyMedium: AppTypography.bodyS,
      bodySmall: AppTypography.bodyS.medium,
      // Captions -> Labels
      labelLarge: AppTypography.captionM.bold,
      labelMedium: AppTypography.captionM.semiBold,
      labelSmall: AppTypography.captionS,
    );
  }

  /// Build TextTheme for dark mode with specified color
  TextTheme buildDarkTextTheme(Color textColor) {
    return buildLightTextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // LEGACY GETTERS (for backward compatibility)
  // ──────────────────────────────────────────────────────────────────────────

  // Display (mapped to headings)
  TextStyle get lightDisplayLarge => AppTypography.headingM;
  TextStyle get lightDisplayMedium => AppTypography.headingS;
  TextStyle get lightDisplaySmall => AppTypography.subheadingM;

  TextStyle get darkDisplayLarge => AppTypography.headingM;
  TextStyle get darkDisplayMedium => AppTypography.headingS;
  TextStyle get darkDisplaySmall => AppTypography.subheadingM;

  // Headlines (mapped to subheadings)
  TextStyle get lightHeadlineLarge => AppTypography.subheadingM;
  TextStyle get lightHeadlineMedium => AppTypography.subheadingS;
  TextStyle get lightHeadlineSmall => AppTypography.subheadingS;

  TextStyle get darkHeadlineLarge => AppTypography.subheadingM;
  TextStyle get darkHeadlineMedium => AppTypography.subheadingS;
  TextStyle get darkHeadlineSmall => AppTypography.subheadingS;

  // Body (mapped to body styles)
  TextStyle get lightBodyLarge => AppTypography.bodyM.bold;
  TextStyle get lightBodyMedium => AppTypography.bodyM;
  TextStyle get lightBodySmall => AppTypography.bodyS;

  TextStyle get darkBodyLarge => AppTypography.bodyM.bold;
  TextStyle get darkBodyMedium => AppTypography.bodyM;
  TextStyle get darkBodySmall => AppTypography.bodyS;

  // Labels (mapped to captions)
  TextStyle get lightLabelLarge => AppTypography.captionM.bold;
  TextStyle get lightLabelMedium => AppTypography.captionM;
  TextStyle get lightLabelSmall => AppTypography.captionS;

  TextStyle get darkLabelLarge => AppTypography.captionM.bold;
  TextStyle get darkLabelMedium => AppTypography.captionM;
  TextStyle get darkLabelSmall => AppTypography.captionS;
}
