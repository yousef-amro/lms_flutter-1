// import 'package:arabgt_app/core/presentation/localization/language_registry.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:arabgt_app/core/cache/local_storage.dart';

// class LocalizationController extends GetxController {
//   static LocalizationController get instance =>
//       Get.find<LocalizationController>();

//   final Rx<AppLanguage> _currentLanguage = LanguageRegistry.supported.first.obs;
//   final RxBool _isLoading = false.obs;

//   final LocalStorageService _localStorage = LocalStorageService();

//   AppLanguage get currentLanguage => _currentLanguage.value;
//   bool get isLoading => _isLoading.value;

//   TextDirection get textDirection =>
//       _currentLanguage.value.isRtl ? TextDirection.rtl : TextDirection.ltr;

//   @override
//   void onInit() {
//     super.onInit();
//     _initLocale();
//   }

//   Future<void> _initLocale() async {
//     final savedTag = _localStorage.locale;
//     final target = savedTag.isNotEmpty
//         ? (LanguageRegistry.findByTag(savedTag) ?? _currentLanguage.value)
//         : _currentLanguage.value;
//     await changeLocale(target, showSpinner: false);
//   }

//   Future<void> changeLocale(AppLanguage lang, {bool showSpinner = true}) async {
//     if (showSpinner) {
//       _isLoading.value = true;
//       update();
//     }
//     try {
//       _currentLanguage.value = lang;
//       _localStorage.locale = lang.tag;
//       await Get.updateLocale(lang.locale);
//     } finally {
//       if (showSpinner) {
//         _isLoading.value = false;
//       }
//     }
//   }

//   Future<void> toggleLanguage() async {
//     final nextTag = _currentLanguage.value.tag == 'en' ? 'ar' : 'en';
//     await changeLocale(LanguageRegistry.findByTag(nextTag)!);
//   }
// }
