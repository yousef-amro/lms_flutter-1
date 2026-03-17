import 'package:get/get.dart';

import '../../../features/auth/binding/auth_binding.dart';
import '../../../features/auth/presentation/login/login_screen.dart';
import '../../../features/home/presentation/home_screen.dart';
import '../../../features/splash/binding/splash_binding.dart';
import '../../../features/splash/presentation/splash_screen.dart';
import 'app_routes.dart';

class AppNavigator {
  static final AppNavigator instance = AppNavigator._internal();
  AppNavigator._internal();

  List<GetPage> get routes {
    return [
      GetPage(
        name: AppRoutes.splash,
        page: () => const SplashScreen(),
        bindings: [SplashBinding()],
      ),

      // Auth
      GetPage(
        name: AppRoutes.login,
        page: () => LoginScreen(),
        bindings: [AuthBinding()],
      ),

      // Home
      GetPage(
        name: AppRoutes.home,
        page: () => const HomeScreen(),
      ),
    ];
  }
}
