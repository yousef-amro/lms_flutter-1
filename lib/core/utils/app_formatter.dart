import 'package:flutter/services.dart';

class AppFormatter {
  //create singleton
  static AppFormatter instance = AppFormatter._internal();

  AppFormatter._internal();

  // Allows only numeric and decimal values.
  List<TextInputFormatter>? numericAndDecimalFormatter() {
    return [FilteringTextInputFormatter.allow(RegExp('[0-9.]'))];
  }

  // Allows only numeric values.
  List<FilteringTextInputFormatter> numericFormatter() {
    return [FilteringTextInputFormatter.allow(RegExp('[0-9]'))];
  }

  // Allows only numeric values.
  List<FilteringTextInputFormatter> phoneNumberFormatter() {
    return [FilteringTextInputFormatter.allow(RegExp('[0-9+]'))];
  }
}
