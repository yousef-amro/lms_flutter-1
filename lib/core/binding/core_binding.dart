import 'package:get/get.dart';
import 'package:lms_app/core/data/data_sources/core_data_remote_data_source.dart';
import 'package:lms_app/core/presentation/controllers/core_data_controller.dart';

class CoreDataBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoreDataRemoteDataSourceAbstraction>(
      () => CoreDataRemoteDataSource(Get.find()),
    );

    Get.put(CoreDataController(repository: Get.find()), permanent: true);
  }
}
