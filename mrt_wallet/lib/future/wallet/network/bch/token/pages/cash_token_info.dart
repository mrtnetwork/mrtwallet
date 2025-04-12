import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class BCHCashTokenDetailsView extends StatelessWidget {
  const BCHCashTokenDetailsView({
    super.key,
    required this.token,
    required this.color,
  });
  final BCHCashToken token;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final CashToken cashToken = token.cashToken;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(cashToken.hasNFT ? "nft".tr : "ft".tr,
            style: color.lableLarge(context)),
        OneLineTextWidget(cashToken.category, style: color.bodyMedium(context)),
        if (cashToken.hasAmount)
          CoinPriceView(
              token: token.token,
              balance: token.balance,
              symbolColor: color,
              style: color.lableLarge(context))
      ],
    );
  }
}
