import 'package:flutter/material.dart';

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

    final scale = frameSize / 375.0;

    final heroHeight = 406.0 * scale;

    final heroImageWidth = width;

    return SizedBox(
      height: heroHeight,
      width: width,
      child: Align(
        alignment: Alignment.topCenter,
        child: Image.asset(
          heroAsset,
          width: heroImageWidth,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
