import 'package:get/get.dart';

import 'language_registry.dart';

class AppLocalization extends Translations {
  static final AppLocalization _instance = AppLocalization._();
  factory AppLocalization() => _instance;
  AppLocalization._();

  @override
  Map<String, Map<String, String>> get keys => LanguageRegistry.asGetXKeys();
}
