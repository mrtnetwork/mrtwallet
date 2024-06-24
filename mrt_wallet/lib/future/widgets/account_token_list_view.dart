import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/assets_image.dart';
import 'package:mrt_wallet/future/widgets/widget_constant.dart';
import 'package:mrt_wallet/models/wallet_models/token/core/core.dart';
import 'container_with_border.dart';
import 'price.dart';

typedef OnTapToken = void Function(TokenCore);

class AccountTokenListView extends StatelessWidget {
  const AccountTokenListView(
      {required this.tokens, this.onTapToken, this.onRemoveWidget, Key? key})
      : super(key: key);
  final List<TokenCore> tokens;
  final OnTapToken? onTapToken;
  final Widget? onRemoveWidget;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: WidgetConstant.noScrollPhysics,
      itemBuilder: (context, index) {
        final TokenCore token = tokens[index];
        return ContainerWithBorder(
          onRemove: onTapToken == null
              ? null
              : () {
                  onTapToken?.call(token);
                },
          onRemoveWidget: onRemoveWidget,
          child: Row(
            children: [
              CircleTokenImgaeView(token.token, radius: 40),
              WidgetConstant.width8,
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(token.token.name, style: context.textTheme.labelLarge),
                  Text(token.issuer!,
                      style: context.textTheme.bodySmall, maxLines: 1),
                  CoinPriceView(
                      liveBalance: token.balance,
                      token: token.token,
                      style: context.textTheme.titleLarge),
                ],
              )),
            ],
          ),
        );
      },
      itemCount: tokens.length,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      shrinkWrap: true,
    );
  }
}
