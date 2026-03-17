import 'package:flutter/material.dart';
import 'package:lms_app/environments/app_environments.dart';

import '../../cache/local_storage_service.dart';

class ColorManager {
  static final ColorManager _instance = ColorManager._();

  ColorManager._();
  factory ColorManager() => _instance;

  // ========== Brand Colors ==========
  // Primary - Used for primary actions (CTA), main buttons, and critical highlights
  // Get current flavor
  AppEnvironments get _currentFlavor => AppEnvironmentHelper().getEnvironment;

  // ========== Brand Colors ==========
  // Primary - Used for primary actions (CTA), main buttons, and critical highlights
  Color get primary {
    switch (_currentFlavor) {
      case AppEnvironments.production:
        return const Color.fromARGB(255, 0, 129, 235); // Blue for supervision
      case AppEnvironments.development:
        return const Color(0xFFC73B38); // Red for specialty
    }
  }

  // Accent - Used for highlights, icons, badges, achievements, and gradients
  final Color accent = const Color(0xFFDFA853);

  // Light Accent - Used for gradients and light highlights
  final Color lightAccent = const Color(0xFFF3DE88);

  // Secondary - Used for secondary UI elements, dividers, or supportive information
  final Color secondary = const Color(0xFF87B6A5);

  // Text Dark - Used for text, backgrounds, headers, and footers
  final Color textDark = const Color(0xFF080307);

  // Neutral Dark - Used for text, backgrounds, headers, and footers
  final Color neutralDark = const Color(0xFF432428);

  // ========== Base Colors ==========
  final Color forceWhite = const Color.fromARGB(255, 255, 255, 255);
  final Color white = const Color.fromARGB(255, 255, 255, 255);
  final Color black = const Color.fromARGB(255, 12, 12, 12);
  final Color disabled = const Color.fromARGB(255, 87, 87, 87);
  final Color border = const Color.fromARGB(255, 204, 204, 204);

  // ========== Compatibility (reference auth UI) ==========
  Color get primaryButton => primary;
  Color get infoBlue => primary;
  Color get hintGray => const Color.fromARGB(255, 160, 160, 160);
  Color get textMuted => neutralDark.withValues(alpha: 0.65);
  Color get titleDark => textDark;
  Color get screenBgLight => scaffoldBackground;

  // ========== Color Scheme ==========
  Color get lightOnPrimary => white;
  Color get lightOnSurface => const Color.fromARGB(255, 42, 42, 42);

  Color get darkOnPrimary => black;
  Color get darkOnSurface => white;

  // ========== Semantics ==========
  Color get error => const Color(0xffE2072C);
  Color get safe => const Color(0xff00CD83);

  // ========== Components ==========
  Color get inputFill {
    if (LocalStorageService().isDarkMode) {
      return const Color.fromARGB(255, 0, 0, 0);
    }
    return const Color(0xffF8F8F8);
  }

  Color get darkColor {
    if (LocalStorageService().isDarkMode) {
      return const Color.fromARGB(255, 92, 86, 86);
    }
    return textDark;
  }

  Color get divider => const Color.fromARGB(255, 220, 220, 220);

  // ========== Background Colors ==========
  Color get scaffoldBackground => const Color(0xFFFAFAFA);
  Color get cardBackground => white;

  // ========== Gradients ==========
  LinearGradient get accentGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDFA853), Color(0xFFF3DE88)],
  );

  // ========== Button Helpers ==========
  Color get primaryButtonBackground => primary;
  Color get primaryButtonText => white;
  Color get primaryButtonHover => const Color(0xFFB33431); // Darkened by ~10%

  Color get secondaryButtonBackground => Colors.transparent;
  Color get secondaryButtonBorder => primary;
  Color get secondaryButtonText => primary;
}
