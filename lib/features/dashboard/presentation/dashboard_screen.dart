import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/presentation/localization/localization_keys.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();
    AppTypography.init();

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        title: Text(
          LocalizationKeys.dashboard.tr,
          style: AppTypography.subheadingM.copyWith(color: colors.textDark),
        ),
      ),
      body: Center(
        child: Text(
          LocalizationKeys.dashboard.tr,
          style: AppTypography.bodyM.copyWith(color: colors.textDark),
        ),
      ),
    );
  }
}

