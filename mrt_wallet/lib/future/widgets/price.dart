import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class PriceTooltipWidget extends StatelessWidget {
  const PriceTooltipWidget(
      {Key? key,
      required this.price,
      required this.symbol,
      required this.currencyName})
      : super(key: key);
  final String price;
  final String symbol;
  final String currencyName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        constraints: const BoxConstraints(maxWidth: 300),
        child: RichText(
            text: TextSpan(
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: theme.colorScheme.onTertiary),
                children: [
              TextSpan(text: price.to3Digits),
              const TextSpan(text: " "),
              TextSpan(
                  text: symbol,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onTertiary)),
              TextSpan(
                  text: " ($currencyName) ",
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onTertiary)),
            ])));
  }
}

class CoinPriceView extends StatelessWidget {
  const CoinPriceView({
    Key? key,
    this.account,
    this.token,
    this.balance,
    this.liveBalance,
    this.style,
    this.symbolColor,
    this.disableTooltip = false,
  })  : assert(
            (token == null && account != null) ||
                (account == null &&
                    (balance != null || liveBalance != null) &&
                    token != null),
            "use account or balance with coinName"),
        super(key: key);

  final CryptoAccountAddress? account;
  final Token? token;
  final BalanceCore? balance;
  final Live<BalanceCore>? liveBalance;
  final TextStyle? style;
  final Color? symbolColor;
  final bool disableTooltip;
  @override
  Widget build(BuildContext context) {
    final Token coin = token ?? account!.network.coinParam.token;
    final theme = Theme.of(context);
    return LiveWidget(() {
      final price = balance?.price ??
          liveBalance?.value.price ??
          account!.address.viewBalance;
      return ToolTipView(
        tooltipWidget: disableTooltip
            ? null
            : PriceTooltipWidget(
                currencyName: coin.name,
                price: price,
                symbol: coin.symbol,
              ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: RichText(
                    textDirection: TextDirection.ltr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        style: style ?? theme.textTheme.labelLarge,
                        children: [
                          TextSpan(text: price.to3Digits),
                          const TextSpan(text: " "),
                        ])),
              ),
              Text(
                coin.symbol,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: symbolColor ?? theme.colorScheme.primary),
              )
            ],
          ),
        ),
      );
    });
  }
}
