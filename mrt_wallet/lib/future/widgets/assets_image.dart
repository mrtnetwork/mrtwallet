import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';

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

class CircleTokenImgaeView extends StatelessWidget {
  const CircleTokenImgaeView(this.token,
      {this.radius = 120,
      this.backgroundColor = Colors.transparent,
      super.key});
  final Token token;
  final double radius;
  final Color backgroundColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          shape: BoxShape.circle, boxShadow: [WidgetConstant.circleShadow]),
      child: CircleAvatar(
        backgroundImage: token.logo != null ? AssetImage(token.logo!) : null,
        radius: radius,
        backgroundColor: context.colors.primaryContainer,
        child: token.logo != null
            ? null
            : Text(
                token.symbol[0],
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: radius,
                    color: context.colors.onPrimaryContainer),
              ),
      ),
    );
  }
}
