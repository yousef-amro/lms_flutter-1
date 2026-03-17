// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/domain/routing/app_routes.dart';
import 'package:lms_app/core/presentation/widgets/app_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/domain/utils/alerts.dart';
import '../../../core/presentation/localization/localization_keys.dart';
import '../data/repository/splash_repo.dart';
import '../domain/models/app_version.dart';

class SplashController extends GetxController with Alerts {
  final SplashRepositoryAbstraction _repository;

  SplashController({required SplashRepositoryAbstraction repository})
    : _repository = repository;

  @override
  void onInit() async {
    super.onInit();
    await Future.delayed(const Duration(seconds: 3));
    // Decide initial route based on cached auth token (and optional update check).
    // If you want connectivity + update flow, call `checkConnectivity()` instead.
    await verifyToken();
  }

  void checkConnectivity() async {
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity.contains(ConnectivityResult.none)) {
      Get.dialog(
        barrierDismissible: false,
        AppDialog(
          dismissible: false,
          title: LocalizationKeys.noConnection.tr,
          description: LocalizationKeys.noConnectionDesc.tr,
          actionText: LocalizationKeys.retry.tr,
          onAction: () {
            Get.back();
            checkConnectivity();
          },
        ),
      );
      return;
    }
    await Future.delayed(const Duration(seconds: 2));

    checkAvailableUpdate();
  }

  void checkAvailableUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final response = await _repository.checkAvailableUpdate(packageInfo);

    response.fold(
      (failure) {
        // If update check fails, continue to auth check
        // This is not a critical failure
        verifyToken();
      },
      (appVersion) {
        switch (appVersion.status) {
          case UpdateStatus.hard:
            Get.dialog(
              barrierDismissible: false,
              AppDialog(
                dismissible: false,
                title: LocalizationKeys.updateAppTitle.tr,
                description: LocalizationKeys.updateAppDescription.tr,
                actionText: LocalizationKeys.updateApp.tr,
                onAction: () => redirectToStore(appVersion.url!),
              ),
            );
          case UpdateStatus.soft:
            Get.dialog(
              barrierDismissible: false,
              AppDialog(
                dismissible: false,
                title: LocalizationKeys.updateAppTitle.tr,
                description: LocalizationKeys.updateAppDescription.tr,
                actionText: LocalizationKeys.updateApp.tr,
                onAction: () => redirectToStore(appVersion.url!),
                cancelText: LocalizationKeys.later.tr,
                onCancel: () {
                  Get.back();
                  verifyToken();
                },
              ),
            );
          case UpdateStatus.none:
            verifyToken();
        }
      },
    );
  }

  Future<void> redirectToStore(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showFailSnackbar(text: LocalizationKeys.somethingWentWrong.tr);
    }
  }

  Future<void> verifyToken() async {
    final accessToken = await _repository.fetchAccessToken();

    if (accessToken.isEmpty) {
      Get.offNamed(AppRoutes.login);
      return;
    } else {
      Get.offNamed(AppRoutes.dashboard);
      return;
    }
  }
}
