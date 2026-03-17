import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms_app/core/domain/constants/svg_manager.dart';

class RegisterHero extends StatelessWidget {
  const RegisterHero({
    super.key,
    required this.width,
    required this.heroAsset,
    required this.readyBanner,
  });

  final double width;
  final String heroAsset;
  final String readyBanner;

  @override
  Widget build(BuildContext context) {
    const heroImageAspectRatio = 305 / 295;

    final frameSize = width * 0.95;
    final frameTop = width * 0.18;

    final ellipseSize = frameSize * (197 / 275);
    final ellipse1Top = frameTop + (frameSize * 0.11);
    final ellipse1Left = (width - frameSize) / 2 + (frameSize * 0.10);
    final ellipse2Top = frameTop + (frameSize * 0.40);
    final ellipse2Left = (width - frameSize) / 2 + (frameSize * 0.45);

    final heroImageWidth = frameSize * 1.18;
    final heroImageHeight = heroImageWidth * heroImageAspectRatio;
    final heroImageTop = width * 0.06;
    final heroImageLeft = (width - heroImageWidth) / 2;
    final heroHeight = heroImageTop + heroImageHeight + 4;

    return SizedBox(
      height: heroHeight,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: frameTop + 18,
            left: (width - frameSize) / 2,
            child: SvgPicture.asset(
              SvgManager().registerHeroFrame,
              width: frameSize,
              height: frameSize,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: ellipse1Top,
            left: ellipse1Left,
            child: SvgPicture.asset(
              SvgManager().registerHeroEllipse,
              width: ellipseSize,
              height: ellipseSize,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: ellipse2Top,
            left: ellipse2Left,
            child: SvgPicture.asset(
              SvgManager().registerHeroEllipse,
              width: ellipseSize,
              height: ellipseSize,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: heroImageTop + 10,
            left: heroImageLeft + 14,
            child: Image.asset(
              heroAsset,
              width: heroImageWidth - 20,
              height: heroImageHeight - 20,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

