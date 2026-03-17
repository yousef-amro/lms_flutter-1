import 'package:get/get.dart';
import 'package:lms_app/core/presentation/localization/localization_keys.dart';

class AppValidator {
  //create singleton
  static AppValidator instance = AppValidator._internal();

  AppValidator._internal();

  // Allows only numeric and decimal values.
  String? mobileValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocalizationKeys.fieldRequired.tr;
    }

    return null;
  }

  String? emptyValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocalizationKeys.fieldRequired.tr;
    }
    return null;
  }
}
