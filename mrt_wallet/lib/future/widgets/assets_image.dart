import 'package:flutter/material.dart';

class CircleAssetsImgaeView extends StatelessWidget {
  const CircleAssetsImgaeView(this.assetPath,
      {this.radius = 120,
      this.backgroundColor = Colors.transparent,
      super.key});
  final String assetPath;
  final double radius;
  final Color backgroundColor;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: AssetImage(assetPath),
      radius: radius,
      backgroundColor: backgroundColor,
    );
  }
}
