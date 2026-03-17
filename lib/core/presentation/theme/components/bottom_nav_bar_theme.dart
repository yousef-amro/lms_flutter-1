import 'package:flutter/material.dart';

import '../color_manager.dart';

class AppBottomNavBarTheme {
  AppBottomNavBarTheme._();
  static final AppBottomNavBarTheme _instance = AppBottomNavBarTheme._();
  factory AppBottomNavBarTheme() => _instance;

  BottomNavigationBarThemeData get lightTheme => BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: ColorManager().lightOnPrimary,
    selectedLabelStyle: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
    unselectedLabelStyle: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
  );

  BottomNavigationBarThemeData get darkTheme => BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: ColorManager().darkOnPrimary,
    selectedLabelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
    selectedItemColor: ColorManager().primary,
    unselectedLabelStyle: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
    ),
  );
}
