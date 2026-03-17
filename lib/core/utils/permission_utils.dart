import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/utils/alerts.dart';
import '../presentation/localization/localization_keys.dart';

class PermissionUtils with Alerts {
  static final PermissionUtils _instance = PermissionUtils._();

  PermissionUtils._();

  factory PermissionUtils() => _instance;

  Future<bool> gallery() async {
    if (Platform.isAndroid) {
      Permission permission = Permission.photos;
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      permission = sdkInt <= 32 ? Permission.storage : Permission.photos;
      final status = await permission.request();

      if (status.isDenied) {
        showFailSnackbar(text: LocalizationKeys.permissionDenied.tr);
        return false;
      }

      if (status.isRestricted || status.isPermanentlyDenied) {
        showFailSnackbar(text: LocalizationKeys.permissionDenied.tr);
        openAppSettings();
        return false;
      }
    }

    return true;
  }

  Future<bool> location() async {
    final permission = Permission.location;
    var status = await permission.status;

    if (status.isGranted) return true;

    // Respect user choice: do not force-open settings; just inform and return.
    if (status.isRestricted || status.isPermanentlyDenied) {
      showFailSnackbar(text: LocalizationKeys.locationPermissionDenied.tr);
      return false;
    }

    status = await permission.request();

    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      showFailSnackbar(text: LocalizationKeys.locationPermissionDenied.tr);
      return false;
    }

    return status.isGranted;
  }
}
