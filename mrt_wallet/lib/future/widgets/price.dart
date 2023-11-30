import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/state_managment/state_managment.dart';
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
              TextSpan(text: price),
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
    this.coinNames,
    this.balance,
    this.style,
    this.symbolColor,
    this.disableTooltip = false,
  })  : assert(
            (balance == null && coinNames == null && account != null) ||
                (account == null && balance != null && coinNames != null),
            "use account or balance with coinName"),
        super(key: key);

  final CryptoAddress? account;
  final NetworkCoinParams? coinNames;
  final CurrencyBalance? balance;
  final TextStyle? style;
  final Color? symbolColor;
  final bool disableTooltip;
  @override
  Widget build(BuildContext context) {
    final NetworkCoinParams coin = coinNames ?? account!.network.coinParam;
    final theme = Theme.of(context);
    return ToolTipView(
      tooltipWidget: disableTooltip
          ? null
          : PriceTooltipWidget(
              currencyName: coin.coinName,
              price: balance?.price ?? account!.address.viewBalance,
              symbol: coin.coinSymbol,
            ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: LiveWidget(() {
                final price = balance?.price ?? account!.address.viewBalance;
                return RichText(
                    textDirection: TextDirection.ltr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        style: style ?? theme.textTheme.labelLarge,
                        children: [
                          TextSpan(text: price),
                          const TextSpan(text: " "),
                        ]));
              }),
            ),
            Text(
              coin.coinSymbol,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: symbolColor ?? theme.colorScheme.primary),
            )
          ],
        ),
      ),
    );
  }
}
