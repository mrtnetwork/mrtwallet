import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/balance/core/balance.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';

class TokenDetailsView extends StatelessWidget {
  const TokenDetailsView({
    super.key,
    required this.token,
    this.onSelect,
    this.onSelectWidget,
    this.onSelectIcon,
    this.backgroundColor,
    this.textColor,
    this.radius = 40,
    this.showBalance = true,
    this.onTapWhenOnRemove = true,
  });
  final TokenCore token;
  final DynamicVoid? onSelect;
  final Widget? onSelectWidget;
  final Widget? onSelectIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final double radius;
  final bool showBalance;
  final bool onTapWhenOnRemove;
  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      onRemove: onSelect,
      onRemoveIcon: onSelectIcon,
      onRemoveWidget: onSelectWidget,
      backgroundColor: backgroundColor,
      onTapWhenOnRemove: onTapWhenOnRemove,
      child: TokenDetailsWidget(
          token: token.token,
          color: textColor ?? context.colors.onPrimaryContainer,
          radius: radius,
          liveBalance: showBalance ? token.balance : null),
    );
  }
}

class TokenDetailsWidget extends StatelessWidget {
  final Token token;
  final double radius;
  final Color? color;
  final Live<BalanceCore>? liveBalance;
  final BalanceCore? balance;
  const TokenDetailsWidget(
      {required this.token,
      this.liveBalance,
      this.balance,
      this.radius = APPConst.double40,
      this.color,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleTokenImageView(token, radius: radius),
        WidgetConstant.width8,
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(token.nameView,
                style: context.textTheme.labelLarge?.copyWith(color: color)),
            if (liveBalance != null || balance != null)
              CoinPriceView(
                liveBalance: liveBalance,
                balance: balance,
                token: token,
                style: context.textTheme.titleLarge?.copyWith(color: color),
                symbolColor: color,
              )
            else
              Text(token.symbolView,
                  style: context.textTheme.labelSmall?.copyWith(color: color)),
          ],
        )),
      ],
    );
  }
}
