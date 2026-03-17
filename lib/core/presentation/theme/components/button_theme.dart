import 'package:flutter/material.dart';

import '../color_manager.dart';

class AppButtonTheme {
  AppButtonTheme._();
  static final AppButtonTheme _instance = AppButtonTheme._();
  factory AppButtonTheme() => _instance;

  ElevatedButtonThemeData get elevatedButton => const ElevatedButtonThemeData();

  OutlinedButtonThemeData get outlinedButton => const OutlinedButtonThemeData();

  TextButtonThemeData get textButton => TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      visualDensity: VisualDensity.compact,
    ),
  );

  FilledButtonThemeData get lightFilledButton => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      foregroundColor: ColorManager().lightOnPrimary,
    ),
  );

  FilledButtonThemeData get darkFilledButton => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      foregroundColor: ColorManager().darkOnPrimary,
    ),
  );
}
