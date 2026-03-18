import 'package:fl_country_code_picker/fl_country_code_picker.dart'
    as flc;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/domain/routing/app_navigator.dart';
import 'package:lms_app/core/domain/routing/app_routes.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';

import '../core/binding/network_core_binding.dart';
import '../core/cache/local_storage_service.dart';
import '../core/cache/secure_storage_service.dart';
import '../core/presentation/localization/app_localization.dart';
import '../core/presentation/localization/language_registry.dart';
import '../core/presentation/theme/app_theme.dart';
import '../core/services/session_manager_service.dart';
import '../core/utils/app_utils.dart';

Future<void> mainApp() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  /// Added to fix the loading white screen at the beginning,
  /// because the design splash is most probably dark color very
  /// contrasted from white
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // final flavorConfig = FlavorConfig.instance;
  // final variables = flavorConfig.variables;
  // await Firebase.initializeApp(
  //   options: variables['firebase_options'],
  //   name: variables['firebase_name'],
  // );

  // if (kDebugMode) OneSignal.Debug.setLogLevel(OSLogLevel.warn);
  // OneSignal.initialize(variables['env'].oneSignalAppId);

  await LocalStorageService().init();
  await SecureStorageService().init();
  await AppUtils.init(LocalStorageService());

  // capture Flutter-specific UI errors
  // FlutterError.onError = (FlutterErrorDetails details) async {
  //   await Sentry.captureException(details.exception, stackTrace: details.stack);
  //   FlutterError.presentError(details);
  // };

  // capture platform-specific and uncaught errors
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   Sentry.captureException(error, stackTrace: stack);
  //   return true; // Prevent app from crashing
  // };

  FlutterNativeSplash.remove();
  // await SentryFlutter.init((options) {
  //   options.dsn = variables['env'].sentryDsn;
  //   options.sendDefaultPii = true;
  //   options.attachScreenshot = true;
  //   options.tracesSampleRate = 0.7; // performance tracing
  //   options.profilesSampleRate = 1.0;
  //   options.replay.onErrorSampleRate = 1.0;
  //   options.replay.sessionSampleRate = 0.3;
  // }, appRunner: () => runApp(const AppWidget()));

  runApp(const AppWidget());
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LMS Call Center App',
      translations: AppLocalization(),
      debugShowCheckedModeBanner: false,
      locale: Locale(LocalStorageService().locale),
      localizationsDelegates: const [
        flc.CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LanguageRegistry.supportedLocales(),
      fallbackLocale: const Locale('ar'),
      theme: AppTheme().light,
      darkTheme: AppTheme().dark,
      themeMode: LocalStorageService().themeMode,
      getPages: AppNavigator.instance.routes,
      initialBinding: NetworkCoreBinding(),
      initialRoute: AppRoutes.splash,
      builder: (context, child) {
        final base = context.isPhone
            ? child!
            : Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: child!,
                ),
              );
        return Stack(
          children: [
            base,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => Get.find<SessionManagerService>()
                            .handleUserLogout(showMessage: true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorManager()
                                .primary
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.logout,
                            color: ColorManager().primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
