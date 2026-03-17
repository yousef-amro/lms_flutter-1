import 'package:flutter_flavor/flutter_flavor.dart';

class ImageManager {
  ImageManager._();
  static final ImageManager _instance = ImageManager._();
  factory ImageManager() => _instance;


  String get logo {
    switch (FlavorConfig.instance.name) {
      case 'development':
        return 'assets/images/logo.png';
      default:
        return 'assets/images/logo.png';
    }
  }
}
