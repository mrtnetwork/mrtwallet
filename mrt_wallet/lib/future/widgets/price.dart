import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
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
    required this.token,
    this.balance,
    this.liveBalance,
    this.style,
    this.symbolColor,
    this.disableTooltip = false,
    this.showTokenImage = false,
  })  : assert(
            (account != null) ||
                (account == null && (balance != null || liveBalance != null)),
            "use account or balance with coinName"),
        super(key: key);

  final CryptoAccountAddress? account;
  final Token token;
  final BalanceCore? balance;
  final Live<BalanceCore>? liveBalance;
  final TextStyle? style;
  final Color? symbolColor;
  final bool disableTooltip;
  final bool showTokenImage;
  @override
  Widget build(BuildContext context) {
    final Token coin = token;
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);

    return LiveWidget(() {
      final price = balance?.price ??
          liveBalance?.value.price ??
          account!.address.viewBalance;
      final ta = wallet.amount(price, token);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showTokenImage) ...[
                    CircleTokenImgaeView(token, radius: 10),
                    WidgetConstant.width8,
                  ],
                  Flexible(
                    child: RichText(
                        textDirection: TextDirection.ltr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                            style: style ?? context.textTheme.labelLarge,
                            children: [
                              TextSpan(text: price.to3Digits),
                              const TextSpan(text: " "),
                            ])),
                  ),
                  Text(
                    coin.symbolView,
                    style: context.textTheme.labelSmall?.copyWith(
                        color: symbolColor ?? context.colors.primary),
                  ),
                ],
              ),
              CoinStringPriceView(
                balance: ta,
                token: wallet.currencyToken,
                symbolColor: symbolColor,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class CoinStringPriceView extends StatelessWidget {
  const CoinStringPriceView({
    Key? key,
    required this.token,
    required this.balance,
    this.style,
    this.symbolColor,
    this.disableTooltip = false,
  }) : super(key: key);

  final Currency token;
  final NoneDecimalBalance? balance;
  final TextStyle? style;
  final Color? symbolColor;
  final bool disableTooltip;
  @override
  Widget build(BuildContext context) {
    if (balance?.isZero ?? true) return WidgetConstant.sizedBox;
    return ToolTipView(
      tooltipWidget: disableTooltip
          ? null
          : PriceTooltipWidget(
              currencyName: token.name,
              price: balance!.price,
              symbol: token.name,
            ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: RichText(
                      textDirection: TextDirection.ltr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                          style: style ??
                              context.textTheme.labelSmall
                                  ?.copyWith(color: symbolColor),
                          children: [
                            TextSpan(text: balance!.viewPrice),
                            const TextSpan(text: " "),
                          ])),
                ),
                Text(
                  token.name,
                  style: context.textTheme.labelSmall
                      ?.copyWith(color: symbolColor ?? context.colors.primary),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
