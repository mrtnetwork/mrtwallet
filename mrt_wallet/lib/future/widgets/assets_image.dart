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
  const CircleTokenImgaeView(this.token, {this.radius = 120, super.key});
  final Token token;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final String symbol =
        (token.name.isEmpty ? "" : token.name[0]).toUpperCase();
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow:
              token.assetLogo != null ? [] : [WidgetConstant.circleShadow]),
      child: CircleAvatar(
        backgroundImage:
            token.assetLogo != null ? AssetImage(token.assetLogo!) : null,
        radius: radius,
        backgroundColor: token.assetLogo != null
            ? context.colors.background
            : context.colors.primaryContainer,
        child: token.assetLogo != null
            ? null
            : Text(
                symbol,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: radius,
                    color: context.colors.onPrimaryContainer),
              ),
      ),
    );
  }
}
