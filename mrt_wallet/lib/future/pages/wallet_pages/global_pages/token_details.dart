import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/address_details.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

enum TokenAction { delete, transfer }

class TokenDetailsModalView extends StatelessWidget {
  const TokenDetailsModalView(
      {super.key, required this.token, required this.address});
  final TokenCore token;
  final CryptoAccountAddress address;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_RippleTokenView(token: token, address: address)],
    );
  }
}

class _RippleTokenView extends StatelessWidget {
  const _RippleTokenView({required this.token, required this.address});
  final TokenCore token;
  final CryptoAccountAddress address;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AddressDetailsView(
            address: address, isSelected: false, showBalance: false),
        const Divider(),
        CircleTokenImgaeView(token.token, radius: 60),
        WidgetConstant.height8,
        RichText(
          text: TextSpan(children: [
            TextSpan(text: token.token.name),
            if (token.type != null)
              TextSpan(
                  text: " (${token.type!.tr}) ",
                  style: context.textTheme.bodySmall)
          ], style: context.textTheme.labelLarge),
        ),
        if (token.issuer != null) SelectableText(token.issuer!),
        WidgetConstant.height8,
        CoinPriceView(
            liveBalance: token.balance,
            token: token.token,
            style: context.textTheme.titleLarge),
        WidgetConstant.height20,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () {
                context.pop(TokenAction.transfer);
              },
              child: const Icon(Icons.upload),
            ),
            WidgetConstant.width8,
            FloatingActionButton(
              onPressed: () {
                context.openSliverDialog(
                    (ctx) => BarcodeView(
                        secure: false,
                        title: AddressDetailsView(
                            address: address,
                            isSelected: false,
                            showBalance: false),
                        barcodeData: address.address.toAddress),
                    "account_qr_code".tr);
              },
              child: const Icon(Icons.download),
            )
          ],
        )
      ],
    );
  }
}
