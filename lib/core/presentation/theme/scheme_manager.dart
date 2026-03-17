import 'package:flutter/material.dart';

import 'color_manager.dart';

class SchemeManager {
  static final SchemeManager _instance = SchemeManager._internal();

  SchemeManager._internal();
  factory SchemeManager() => _instance;

  ColorScheme get lightScheme => ColorScheme.light(
    primary: ColorManager().primary,
    brightness: Brightness.light,
    onPrimary: ColorManager().lightOnPrimary,
    onSurface: ColorManager().lightOnSurface,
    error: ColorManager().error,
  );

  ColorScheme get darkScheme => ColorScheme.dark(
    primary: ColorManager().primary,
    brightness: Brightness.dark,
    onPrimary: ColorManager().darkOnPrimary,
    onSurface: ColorManager().darkOnSurface,
    error: ColorManager().error,
  );

  List<BoxShadow> get mainShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      offset: const Offset(0, 0),
      blurRadius: 5.0,
    ),
  ];
}
