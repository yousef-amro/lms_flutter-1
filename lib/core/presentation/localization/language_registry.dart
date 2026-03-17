import 'dart:ui';

import 'package:get/get.dart';

import 'languages/ar.dart';
import 'languages/en.dart';

typedef BundleBuilder = Map<String, String> Function();

class AppLanguage {
  final String tag; // e.g., "ar", "en"
  final bool isRtl;
  final String name; // UI label e.g., "العربية", "English"
  final BundleBuilder bundle;

  const AppLanguage({
    required this.tag,
    required this.isRtl,
    required this.name,
    required this.bundle,
  });

  Locale get locale => Locale(tag);
}

class LanguageRegistry {
  static final List<AppLanguage> supported = [
    AppLanguage(
      tag: 'ar',
      isRtl: true,
      name: 'العربية',
      bundle: () => Ar().map,
    ),
    AppLanguage(
      tag: 'en',
      isRtl: false,
      name: 'English',
      bundle: () => En().map,
    ),
  ];

  static Map<String, Map<String, String>> asGetXKeys() => {
        for (final l in supported) l.tag: l.bundle(),
      };

  static List<Locale> supportedLocales() => [
        for (final l in supported) l.locale,
      ];

  static AppLanguage? findByTag(String tag) {
    final t = tag.toLowerCase();
    return supported.firstWhereOrNull((l) => l.tag.toLowerCase() == t);
  }
}
