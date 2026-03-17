import 'package:flutter/material.dart';

import '../components/login_hero.dart';

class LoginHeaderSection extends StatelessWidget {
  const LoginHeaderSection({
    super.key,
    required this.width,
    required this.scale,
    required this.heroAsset,
    required this.title,
  });

  final double width;
  final double scale;
  final String heroAsset;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoginHero(width: width, heroAsset: heroAsset),
        SizedBox(height: 25 * scale),
      ],
    );
  }
}
