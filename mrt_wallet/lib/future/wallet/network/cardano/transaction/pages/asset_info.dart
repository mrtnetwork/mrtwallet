import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/wallet/models/networks/cardano/models/utxo_multi_asset.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class CardanoAssetsInfoView extends StatelessWidget {
  const CardanoAssetsInfoView({super.key, required this.asset});
  final UtxoMultiAsset asset;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(asset.assets.length, (index) {
        final pl = asset.assets.keys.toList()[index];
        final assets = asset.assets[pl]!;
        if (assets.assets.isEmpty) return WidgetConstant.sizedBox;
        return ListView.separated(
          itemBuilder: (context, pos) {
            final assetName = assets.assets.keys.toList()[pos];
            final token = Token(name: assetName.name, symbol: assetName.name);
            return ContainerWithBorder(
              padding: EdgeInsets.zero,
              child: TokenDetailsWidget(
                  token: token,
                  balance: assets.assets[assetName],
                  color: context.onPrimaryContainer),
            );
          },
          itemCount: assets.assets.length,
          shrinkWrap: true,
          separatorBuilder: (context, index) => WidgetConstant.divider,
        );
      }),
    );
  }
}
