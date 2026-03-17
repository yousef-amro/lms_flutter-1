// import 'package:app_links/app_links.dart';
// import 'package:flutter/material.dart';
// import 'package:e_commerce_user_app/core/domain/routing/app_routes.dart';
// import 'package:get/get.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';

// import '../presentation/localization/localization_keys.dart';
// import '../presentation/theme/color_manager.dart';

// class AppDeepLinkingService {
//   static Future<void> init() async {
//     final appLinks = AppLinks();

//     final uri = await appLinks.getInitialLink();

//     OneSignal.Notifications.addClickListener((event) {
//       final payload = event.notification.additionalData;

//       if (payload?['url'] != null) {
//         handleUri(Uri.tryParse(payload!['url']));
//         return;
//       }
//     });

//     appLinks.uriLinkStream.listen((uri) {
//       handleUri(uri);
//     });

//     handleUri(uri);
//   }

//   static void handleUri(Uri? uri) {
//     if (uri == null) return;
//     final isGuest = Get.find<ProfileController>().user.value.isGuest;
//     final path = uri.path;
//     if (isGuest && path == AppRoutes.questionDetail) {
//       _showGuestSnackbar();
//       return;
//     }
//     final id = int.tryParse(uri.queryParameters['id'] ?? '');
//     Get.toNamed(path, arguments: id, preventDuplicates: false);
//   }

//   static void _showGuestSnackbar() {
//     Get.showSnackbar(
//       GetSnackBar(
//         messageText: Text(
//           LocalizationKeys.youNeedToBeLoggedInToView.tr,
//           style: TextStyle(
//             fontSize: 14,
//             fontFamily: 'Cairo',
//             color: ColorManager().lightOnPrimary,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         shouldIconPulse: false,
//         borderColor: ColorManager().lightOnPrimary,
//         backgroundColor: ColorManager().error,
//         borderRadius: 4,
//         snackStyle: SnackStyle.FLOATING,
//         margin: const EdgeInsets.all(20),
//         padding: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 4),
//       ),
//     );
//   }
// }
