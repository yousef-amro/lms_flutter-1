import 'package:flutter_flavor/flutter_flavor.dart';

import '../_main.dart';
import '../app_environments.dart';

void main() {
  FlavorConfig(
    name: AppEnvironments.production.name,
    variables: AppEnvironments.production.variables,
  );
  mainApp();
}
