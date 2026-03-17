import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:lms_app/environments/app_environments.dart';

import '../_main.dart';

void main() {
  FlavorConfig(
    name: AppEnvironments.development.name,
    variables: AppEnvironments.development.variables,
    location: BannerLocation.bottomEnd,
  );
  mainApp();
}
