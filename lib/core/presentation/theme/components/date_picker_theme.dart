import 'package:flutter/material.dart';

import '../color_manager.dart';
import 'text_theme.dart';

class AppDatePickerTheme {
  AppDatePickerTheme._();
  static final AppDatePickerTheme _instance = AppDatePickerTheme._();
  factory AppDatePickerTheme() => _instance;

  DatePickerThemeData get lightDatePicker => DatePickerThemeData(
    backgroundColor: ColorManager().lightOnPrimary,
    headerBackgroundColor: ColorManager().primary,
    headerForegroundColor: ColorManager().lightOnPrimary,
    headerHeadlineStyle: AppTextTheme().lightTheme.bodyLarge,
    headerHelpStyle: AppTextTheme().lightTheme.labelLarge,
    yearStyle: AppTextTheme().lightTheme.labelLarge,
    dayStyle: AppTextTheme().lightTheme.labelMedium,
    weekdayStyle: AppTextTheme().lightTheme.labelLarge,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  DatePickerThemeData get darkDatePicker => DatePickerThemeData(
    backgroundColor: ColorManager().darkOnPrimary,
    headerBackgroundColor: ColorManager().primary,
    headerForegroundColor: ColorManager().darkOnPrimary,
    headerHeadlineStyle: AppTextTheme().darkTheme.bodyLarge,
    headerHelpStyle: AppTextTheme().darkTheme.labelLarge,
    yearStyle: AppTextTheme().darkTheme.labelLarge,
    dayStyle: AppTextTheme().darkTheme.labelMedium,
    weekdayStyle: AppTextTheme().darkTheme.labelLarge,
  );
}
