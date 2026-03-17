import 'package:flutter/material.dart';

import '../text_manager.dart';

class AppTextTheme {
  AppTextTheme._();
  static final AppTextTheme _instance = AppTextTheme._();
  factory AppTextTheme() => _instance;

  TextTheme get lightTheme => TextTheme(
    headlineLarge: TextManager().lightHeadlineLarge,
    headlineMedium: TextManager().lightHeadlineMedium,
    headlineSmall: TextManager().lightHeadlineSmall,
    labelLarge: TextManager().lightLabelLarge,
    labelMedium: TextManager().lightLabelMedium,
    labelSmall: TextManager().lightLabelSmall,
    bodyLarge: TextManager().lightBodyLarge,
    bodyMedium: TextManager().lightBodyMedium,
    bodySmall: TextManager().lightBodySmall,
  );

  TextTheme get darkTheme => TextTheme(
    headlineLarge: TextManager().darkHeadlineLarge,
    headlineMedium: TextManager().darkHeadlineMedium,
    headlineSmall: TextManager().darkHeadlineSmall,
    labelLarge: TextManager().darkLabelLarge,
    labelMedium: TextManager().darkLabelMedium,
    labelSmall: TextManager().darkLabelSmall,
    bodyLarge: TextManager().darkBodyLarge,
    bodyMedium: TextManager().darkBodyMedium,
    bodySmall: TextManager().darkBodySmall,
  );
}
