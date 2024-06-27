import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/token/core/core.dart';

class TokenDetailsView extends StatelessWidget {
  const TokenDetailsView({
    super.key,
    required this.token,
    this.onSelect,
    this.onSelectWidget,
    this.onSelectIcon,
    this.backgroundColor,
  });
  final TokenCore token;
  final DynamicVoid? onSelect;
  final Widget? onSelectWidget;
  final Widget? onSelectIcon;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      onRemove: onSelect,
      onRemoveIcon: onSelectIcon,
      onRemoveWidget: onSelectWidget,
      backgroundColor: backgroundColor,
      child: Row(
        children: [
          CircleTokenImgaeView(token.token, radius: 40),
          WidgetConstant.width8,
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(token.token.name, style: context.textTheme.labelLarge),
              CoinPriceView(
                  liveBalance: token.balance,
                  token: token.token,
                  style: context.textTheme.titleLarge),
            ],
          )),
        ],
      ),
    );
  }
}
