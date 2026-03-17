import 'package:flutter/material.dart';

import 'color_manager.dart';
import 'components/bottom_nav_bar_theme.dart';
import 'components/button_theme.dart';
import 'components/date_picker_theme.dart';
import 'components/input_theme.dart';
import 'components/popup_menu_theme.dart';
import 'components/text_theme.dart';
import 'scheme_manager.dart';

class AppTheme {
  AppTheme._();
  static final AppTheme _instance = AppTheme._();
  factory AppTheme() => _instance;

  ThemeData get light => ThemeData(
    useMaterial3: true,
    primaryColor: ColorManager().primary,
    brightness: Brightness.light,
    scaffoldBackgroundColor: ColorManager().lightOnPrimary,
    fontFamily: 'Cairo',
    textTheme: AppTextTheme().lightTheme,
    colorScheme: SchemeManager().lightScheme,
    dividerTheme: DividerThemeData(
      color: ColorManager().primary.withValues(alpha: 0.5),
      thickness: 1.4,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorManager().primary.withAlpha(5),
      titleTextStyle: TextStyle(
        color: ColorManager().lightOnSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    filledButtonTheme: AppButtonTheme().lightFilledButton,
    textButtonTheme: AppButtonTheme().textButton,
    inputDecorationTheme: AppInputTheme().textField,
    bottomNavigationBarTheme: AppBottomNavBarTheme().lightTheme,
    popupMenuTheme: AppPopupMenuTheme().lightPopupMenu,
    datePickerTheme: AppDatePickerTheme().lightDatePicker,
    iconTheme: IconThemeData(color: ColorManager().lightOnSurface),
  );

  ThemeData get dark => ThemeData(
    useMaterial3: true,
    primaryColor: ColorManager().primary,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorManager().darkOnPrimary,
    fontFamily: 'Cairo',
    textTheme: AppTextTheme().darkTheme,
    colorScheme: SchemeManager().darkScheme,
    dividerTheme: DividerThemeData(
      color: ColorManager().primary.withValues(alpha: 0.5),
      thickness: 1.4,
    ),
    filledButtonTheme: AppButtonTheme().darkFilledButton,
    textButtonTheme: AppButtonTheme().textButton,
    inputDecorationTheme: AppInputTheme().textField,
    bottomNavigationBarTheme: AppBottomNavBarTheme().darkTheme,
    popupMenuTheme: AppPopupMenuTheme().darkPopupMenu,
    datePickerTheme: AppDatePickerTheme().darkDatePicker,
    iconTheme: IconThemeData(color: ColorManager().darkOnSurface),
  );
}
