// import 'package:get/get.dart';

// enum SettingsState { initial, loading, success, failure }

// class SettingsController extends GetxController with Alerts {
//   SettingsController({required this.repository});

//   final CoreRemoteDataSourceAbstraction repository;
//   SettingsState settingsState = SettingsState.initial;

//   final settings = Settings.empty().obs;

//   @override
//   Future<void> onInit() async {
//     await fetchSettings();
//     super.onInit();
//   }

//   Future<void> fetchSettings() async {
//     if (Get.find<ProfileController>().user.value.isGuest) return;
//     settingsState = SettingsState.loading;

//     final result = await repository.fetchSettings();

//     result.fold(
//       (failure) {
//         settingsState = SettingsState.failure;
//       },
//       (settings) {
//         settingsState = SettingsState.success;
//         this.settings.value = settings;
//       },
//     );
//   }
// }
