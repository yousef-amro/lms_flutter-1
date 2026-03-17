import 'package:flutter_flavor/flutter_flavor.dart';

enum AppEnvironments {
  production,
  development;

  Map<String, dynamic> get variables {
    switch (this) {
      case AppEnvironments.production:
        return {
          'BASE_URL': 'https://lms-giwum.ondigitalocean.app',
          // 'WEBSOCKET_URL': 'wss://sound-level.vision-jo.com/ws/sensor-data/',
          // 'firebase_options':
          //     firebase_supervision.DefaultFirebaseOptions.currentPlatform,
          // 'firebase_name': 'sound-level-28c39',
        };
      case AppEnvironments.development:
        return {
          'BASE_URL': 'https://lms-giwum.ondigitalocean.app',
          // 'WEBSOCKET_URL': 'wss://sound-level.vision-jo.com/ws/sensor-data/',
          // 'firebase_options':
          //     firebase_specialty.DefaultFirebaseOptions.currentPlatform,
          // 'firebase_name': 'sound-level-28c39',
        };
    }
  }
}

class AppEnvironmentHelper {
  AppEnvironments get getEnvironment =>
      _environmentNameMapper(FlavorConfig.instance.name!);

  dynamic getEnvironmentVariable(String variableName) {
    return getEnvironment.variables[variableName];
  }

  AppEnvironments _environmentNameMapper(String flavorName) {
    if (flavorName == AppEnvironments.production.name) {
      return AppEnvironments.production;
    } else if (flavorName == AppEnvironments.development.name) {
      return AppEnvironments.development;
    }

    throw UnimplementedError();
  }
}
