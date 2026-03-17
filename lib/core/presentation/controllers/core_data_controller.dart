import 'package:get/get.dart';
import 'package:lms_app/core/data/data_sources/core_data_remote_data_source.dart';

enum CoreState { initial, loading, success, failure }

class CoreDataController extends GetxController {
  final CoreDataRemoteDataSourceAbstraction repository;

  CoreDataController({required this.repository});

  // final cities = <CoreModel>[].obs;

  final Rx<CoreState> citiesState = CoreState.initial.obs;

  // Future<void> fetchCities() async {
  //   citiesState.value = CoreState.loading;
  //   final result = await repository.fetchCities();
  //   result.fold(
  //     (failure) {
  //       citiesState.value = CoreState.failure;
  //     },
  //     (data) {
  //       cities.assignAll(data);
  //       citiesState.value = CoreState.success;
  //     },
  //   );
  // }
}
