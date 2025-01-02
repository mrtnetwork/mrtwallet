import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/token/chains_tokens/cw20.dart';

class CosmosTransactionPickTokenView extends StatelessWidget {
  const CosmosTransactionPickTokenView(
      {this.address, this.tokens, this.title, super.key})
      : assert(address != null || tokens != null,
            "choose address or tokens to pick token");
  final ICosmosAddress? address;
  final List<CW20Token>? tokens;
  final Widget? title;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      title ??
          PageTitleSubtitle(
              title: 'pick_token'.tr,
              body: LargeTextView([
                "cosmos_pick_token_transfer_desc".tr,
                "cosmos_transfer_import_token_desc".tr
              ])),
      _CosmosPickTokens(tokens ?? address?.tokens ?? [])
    ]);
  }
}

class _CosmosPickTokens extends StatelessWidget {
  final List<CW20Token> tokens;
  const _CosmosPickTokens(this.tokens);

  @override
  Widget build(BuildContext context) {
    return ConditionalWidget(
      enable: tokens.isNotEmpty,
      onDeactive: (context) => WidgetConstant.divider,
      onActive: (context) => ListView.separated(
        shrinkWrap: true,
        itemCount: tokens.length,
        itemBuilder: (context, index) {
          final token = tokens[index];
          return TokenDetailsView(
            onSelectIcon: WidgetConstant.sizedBox,
            onSelect: () {
              context.pop(token);
            },
            token: token,
          );
        },
        separatorBuilder: (context, index) => WidgetConstant.divider,
      ),
    );
  }
}
