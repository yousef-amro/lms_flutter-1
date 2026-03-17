import 'package:flutter/material.dart';

import '../color_manager.dart';

class AppInputTheme {
  AppInputTheme._();
  static final AppInputTheme _instance = AppInputTheme._();
  factory AppInputTheme() => _instance;

  InputDecorationTheme get textField => InputDecorationTheme(
    border: const UnderlineInputBorder(borderSide: BorderSide(width: 2)),
    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(width: 2)),
    errorBorder: const UnderlineInputBorder(borderSide: BorderSide(width: 2)),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(width: 2, color: ColorManager().primary),
    ),
    // This is added to give padding without affecting the
    // padding of the error text, adding start padding also affects
    // error text from validation.
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );
}
