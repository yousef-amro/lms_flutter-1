import 'package:flutter/material.dart';

import '../color_manager.dart';
import 'text_theme.dart';

class AppPopupMenuTheme {
  AppPopupMenuTheme._();
  static final AppPopupMenuTheme _instance = AppPopupMenuTheme._();
  factory AppPopupMenuTheme() => _instance;

  PopupMenuThemeData get lightPopupMenu => PopupMenuThemeData(
    color: ColorManager().lightOnPrimary,
    labelTextStyle: WidgetStatePropertyAll(
      AppTextTheme().lightTheme.labelLarge,
    ),
  );

  PopupMenuThemeData get darkPopupMenu => PopupMenuThemeData(
    color: ColorManager().darkOnPrimary,
    labelTextStyle: WidgetStatePropertyAll(AppTextTheme().darkTheme.labelLarge),
  );
}
