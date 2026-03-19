import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/domain/constants/image_manager.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';

import 'splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = controller;
    const designWidth = 393.0;
    final scale = MediaQuery.of(context).size.width / designWidth;

    return Scaffold(
      backgroundColor: ColorManager().white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: ColorManager().white,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: -206 * scale,
              top: -212 * scale,
              child: _SplashCircle(
                size: 554 * scale,
                strokeColor: const Color(0xFF3185FF).withValues(alpha: 0.18),
                strokeWidth: 1 * scale,
              ),
            ),
            Positioned(
              left: -422 * scale,
              top: 83 * scale,
              child: _SplashCircle(
                size: 554 * scale,
                strokeColor: ColorManager().infoBlue.withValues(alpha: 0.14),
                strokeWidth: 1 * scale,
              ),
            ),
            Center(
              child: SizedBox(
                width: 198 * scale,
                height: 189 * scale,
                child: Image.asset(ImageManager().logo, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashCircle extends StatelessWidget {
  const _SplashCircle({
    required this.size,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final double size;
  final Color strokeColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: strokeColor, width: strokeWidth),
        ),
      ),
    );
  }
}
