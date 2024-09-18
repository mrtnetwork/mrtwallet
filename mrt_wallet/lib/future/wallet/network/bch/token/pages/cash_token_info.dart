import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class BCHCashTokenDetailsView extends StatelessWidget {
  const BCHCashTokenDetailsView({super.key, required this.token});
  final BCHCashToken token;
  @override
  Widget build(BuildContext context) {
    final CashToken cashToken = token.cashToken;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: OneLineTextWidget(cashToken.category)),
            WidgetConstant.width8,
            RichText(
                text: TextSpan(style: context.textTheme.labelLarge, children: [
              TextSpan(text: cashToken.hasNFT ? "nft".tr : "ft".tr),
              if (cashToken.hasNFT) ...[
                const TextSpan(text: "-"),
                TextSpan(text: cashToken.capability!.name.tr),
              ]
            ])),
          ],
        ),
        if (cashToken.hasCommitment) ...[
          OneLineTextWidget(cashToken.commitmentInHex ?? "")
        ],
        if (cashToken.hasAmount)
          CoinPriceView(
            token: token.token,
            balance: token.balance,
          )
      ],
    );
  }
}
