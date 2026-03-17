import 'package:flutter/material.dart';

import '../components/register_hero.dart';
import '../components/register_title.dart';

class RegisterHeaderSection extends StatelessWidget {
  const RegisterHeaderSection({
    super.key,
    required this.width,
    required this.scale,
    required this.heroAsset,
    required this.title,
    required this.readyBanner,
  });

  final double width;
  final double scale;
  final String heroAsset;
  final String title;
  final String readyBanner;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RegisterHero(
          width: width - (56 * scale),
          heroAsset: heroAsset,
          readyBanner: readyBanner,
        ),
        SizedBox(height: 5 * scale),
        RegisterTitle(title: title, scale: scale),
      ],
    );
  }
}

