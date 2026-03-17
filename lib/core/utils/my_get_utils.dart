import 'package:get/get.dart';

class MyGetUtils {
  static final MyGetUtils _instance = MyGetUtils._();
  factory MyGetUtils() => _instance;
  MyGetUtils._();

  T find<T extends GetxController>(T controller, {bool permanent = false}) {
    if (!Get.isRegistered<T>()) {
      Get.put<T>(controller);
    }
    return Get.find<T>();
  }

  T findService<T extends GetxService>(T service) {
    if (!Get.isRegistered<T>()) {
      Get.put<T>(service);
    }
    return Get.find<T>();
  }

  void put<T extends GetxController>(T controller, {bool permanent = false}) {
    if (!Get.isRegistered<T>()) {
      Get.put<T>(controller, permanent: permanent);
    }
  }

  void delete<T extends GetxController>(T controller, {bool force = false}) {
    if (Get.isRegistered<T>()) {
      Get.delete<T>(force: force);
    }
  }

  void lazyPut<T extends GetxController>(
    T Function() controller,
  ) {
    if (!Get.isRegistered<T>()) {
      Get.lazyPut<T>(controller);
    }
  }

  void putAsync<T extends GetxController>(
    Future<T> Function() controller, {
    bool permanent = false,
  }) {
    if (!Get.isRegistered<T>()) {
      Get.putAsync<T>(controller, permanent: permanent);
    }
  }

  void create<T extends GetxController>(
    T Function() controller, {
    bool permanent = false,
  }) {
    if (!Get.isRegistered<T>()) {
      Get.create<T>(controller, permanent: permanent);
    }
  }

  T getController<T extends GetxController>(T controller,
      {bool permanent = false}) {
    if (Get.isRegistered<T>()) {
      return Get.find<T>();
    } else {
      Get.put<T>(controller, permanent: permanent);
      return Get.find<T>();
    }
  }
}
