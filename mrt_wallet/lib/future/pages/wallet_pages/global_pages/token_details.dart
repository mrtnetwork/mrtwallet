import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/address_details.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/global_pages/update_tokens.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

enum TokenAction { delete, transfer }

class TokenDetailsModalView extends StatelessWidget {
  const TokenDetailsModalView(
      {super.key,
      required this.token,
      required this.address,
      required this.transferPath});
  final TokenCore token;
  final CryptoAccountAddress address;
  final String transferPath;
  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        SliverAppBar(
          title: Text("token_info".tr),
          leading: WidgetConstant.sizedBox,
          leadingWidth: 0,
          pinned: true,
          actions: [
            IconButton(
                onPressed: () {
                  context
                      .openSliverBottomSheet<Token>(
                    "update_token".tr,
                    child: UpdateTokenDetailsView(token: token.token),
                  )
                      .then((value) {
                    if (value != null) {
                      wallet
                          .updateToken(
                              token: token,
                              updatedToken: value,
                              address: address)
                          .then((value) {
                        if (value.hasError) return;
                        context.pop();
                      });
                    }
                  });
                },
                icon: const Icon(Icons.edit)),
            IconButton(
                onPressed: () {
                  context.openSliverDialog(
                      (ctx) => DialogTextView(
                          buttomWidget: AsyncDialogDoubleButtonView(
                            firstButtonPressed: () => wallet
                                .removeToken(token, address)
                                .then((value) {
                              if (value.hasError) return;
                              context.pop();
                            }),
                          ),
                          text: "remove_token_from_account".tr),
                      "remove_token".tr);
                },
                icon: Icon(Icons.delete, color: context.colors.error)),
            const CloseButton(),
            WidgetConstant.width8,
          ],
        ),
        SliverToBoxAdapter(
          child: ConstraintsBoxView(
            padding: WidgetConstant.padding20,
            child: _TokenDetailsView(
              token: token,
              address: address,
              wallet: wallet,
              transferPath: transferPath,
            ),
          ),
        ),
      ],
    );
  }
}

class _TokenDetailsView extends StatelessWidget {
  const _TokenDetailsView(
      {required this.token,
      required this.address,
      required this.wallet,
      required this.transferPath});
  final TokenCore token;
  final CryptoAccountAddress address;
  final WalletProvider wallet;
  final String transferPath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AddressDetailsView(address: address, showBalance: false),
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
                context.offTo(transferPath, argruments: token);
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
                            address: address, showBalance: false),
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
