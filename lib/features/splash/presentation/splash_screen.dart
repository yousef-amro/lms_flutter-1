import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/domain/constants/image_manager.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';

import 'splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController(repository: Get.find()));
    return Scaffold(
      body: Container(
        color: ColorManager().white,
        width: double.infinity,
        height: double.infinity,
        child: Center(child: Image.asset(ImageManager().logo)),
      ),
    );
  }
}
