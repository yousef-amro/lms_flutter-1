import 'package:get/get.dart';

import '../../presentation/localization/localization_keys.dart';

abstract class Failure {
  final String message;

  Failure({required this.message});
}

class UnAuthenticatedFailure implements Failure {
  final String? failureMessage;
  final List<String>? errorMessages;

  UnAuthenticatedFailure({this.failureMessage, this.errorMessages});

  @override
  String get message {
    if (failureMessage != null && failureMessage!.isNotEmpty) {
      return failureMessage!;
    }

    if (errorMessages != null && errorMessages!.isNotEmpty) {
      return errorMessages!.join('\n');
    }

    return 'Authentication failed';
  }
}

class InternetFailure implements Failure {
  final String? failureMessage;

  InternetFailure({this.failureMessage});
  @override
  String get message => failureMessage ?? LocalizationKeys.internetFailure.tr;
}

class ServerFailure implements Failure {
  final String? failureMessage;
  final List<String>? errorMessages;

  ServerFailure({this.failureMessage, this.errorMessages});

  @override
  String get message {
    if (failureMessage != null && failureMessage!.isNotEmpty) {
      return failureMessage!;
    }

    if (errorMessages != null && errorMessages!.isNotEmpty) {
      return errorMessages!.join('\n');
    }

    return LocalizationKeys.serverFailure.tr;
  }
}

/// Used if any of the fetched data from third party sdks fails.
/// For example, when using facebook or google sign in, an access token &
/// an id token is required for the backend request, if they are returned null
/// this failure will be thrown
class ThirdPartyFailure implements Failure {
  final String? failureMessage;

  ThirdPartyFailure({this.failureMessage});
  @override
  String get message =>
      failureMessage ?? LocalizationKeys.providerDataFailed.tr;
}
