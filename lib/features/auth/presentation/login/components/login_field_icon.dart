import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginFieldIcon extends StatelessWidget {
  const LoginFieldIcon({
    super.key,
    required this.asset,
    this.color,
    this.scale = 1,
  });

  final String asset;
  final Color? color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: 20 * scale,
      height: 20 * scale,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

