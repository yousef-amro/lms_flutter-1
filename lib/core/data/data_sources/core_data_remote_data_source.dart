import 'package:dartz/dartz.dart';
import 'package:lms_app/core/data/networking/data/network_request.dart';
import 'package:lms_app/core/data/networking/data/network_response.dart';
import 'package:lms_app/core/data/networking/data/network_router.dart';
import 'package:lms_app/core/data/networking/network_adapter.dart';
import 'package:lms_app/core/domain/errors/failure.dart';

abstract class CoreDataRemoteDataSourceAbstraction {
  Future<Either<Failure, bool>> registerFcmToken({
    required String registrationId,
    required String deviceType,
    required String deviceId,
  });
}

class CoreDataRemoteDataSource implements CoreDataRemoteDataSourceAbstraction {
  final NetworkAdapterAbstraction _networkAdapter;

  CoreDataRemoteDataSource(this._networkAdapter);

  @override
  Future<Either<Failure, bool>> registerFcmToken({
    required String registrationId,
    required String deviceType,
    required String deviceId,
  }) async {
    final request = NetworkRequest(
      route: NetworkRouter.fcmRegister,
      requestType: RequestType.post,
      isAuthorizationRequired: true,
      data: {
        'registration_id': registrationId,
        'device_type': deviceType,
        'device_id': deviceId,
      },
    );

    final response = await _networkAdapter.request(request);
    if (response.status == NetworkResponseStatus.success) {
      return const Right(true);
    } else {
      return Left(response.failure!);
    }
  }
}
