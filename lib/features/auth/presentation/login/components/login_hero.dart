import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms_app/core/domain/constants/svg_manager.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';

class LoginHero extends StatelessWidget {
  const LoginHero({
    super.key,
    required this.width,
    required this.heroAsset,
  });

  final double width;
  final String heroAsset;

  @override
  Widget build(BuildContext context) {
    final frameSize = width * .89;
    final frameLeft = (width - frameSize) / 2;
    final scale = frameSize / 375.0;

    final heroHeight = 406.0 * scale;
    final frameTop = 50.0 * scale;

    final ellipseSize = 197.0 * scale;
    final ellipse1Top = 70.0 * scale;
    final ellipse1Left = 45.5 * scale;
    final ellipse2Top = 143.0 * scale;
    final ellipse2Left = 143.5 * scale;

    final heroImageWidth = 295.0 * scale;
    final heroImageTop = 0.0;
    final heroImageLeft = (width - heroImageWidth) / 2 + (1.5 * scale);

    return SizedBox(
      height: heroHeight,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: frameTop,
            left: frameLeft,
            child: SvgPicture.asset(
              SvgManager().loginHeroFrame,
              width: frameSize,
              height: frameSize,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: ellipse1Top,
            left: frameLeft + ellipse1Left,
            child: _CircleOutline(size: ellipseSize),
          ),
          Positioned(
            top: ellipse2Top,
            left: frameLeft + ellipse2Left,
            child: _CircleOutline(size: ellipseSize),
          ),
          Positioned(
            top: heroImageTop - 4 * scale,
            left: heroImageLeft - 20 * scale,
            child: Image.asset(
              heroAsset,
              width: heroImageWidth + 50 * scale,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleOutline extends StatelessWidget {
  const _CircleOutline({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ColorManager().primaryButton.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
    );
  }
}

