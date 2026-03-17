import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoUtils {
  static final DeviceInfoUtils _instance = DeviceInfoUtils._();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  DeviceInfoUtils._();

  factory DeviceInfoUtils() => _instance;

  /// Get device type ('android' or 'ios')
  String getDeviceType() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    }
    return 'unknown';
  }

  /// Get unique device ID
  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Use androidId as unique device identifier
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // Use identifierForVendor as unique device identifier
        return iosInfo.identifierForVendor ?? 'unknown_ios_device';
      }
      return 'unknown_device';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device ID: $e');
      }
      return 'unknown_device';
    }
  }

  /// Get device name/model
  Future<String> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.name;
      }
      return 'Unknown Device';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting device name: $e');
      }
      return 'Unknown Device';
    }
  }
}
