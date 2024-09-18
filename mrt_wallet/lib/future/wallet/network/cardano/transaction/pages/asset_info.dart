import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...List.generate(assets.assets.length, (pos) {
              final assetName = assets.assets.keys.toList()[pos];
              final token = Token(name: assetName.name, symbol: assetName.name);
              return Padding(
                padding: WidgetConstant.padding5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: RichText(
                        maxLines: 1,
                        text: TextSpan(
                            style: context.textTheme.bodyMedium,
                            children: [
                              TextSpan(text: assetName.name),
                              const TextSpan(text: " "),
                              WidgetSpan(
                                child: ToolTipView(
                                  waitDuration: APPConst.milliseconds100,
                                  message: "${"policy_id".tr}: ${pl.toHex()}",
                                  child: Text(
                                    "(${pl.toHex().substring(0, 3)}...)",
                                    style: context.textTheme.labelSmall,
                                  ),
                                ),
                              )
                            ]),
                      ),
                    ),
                    Flexible(
                        child: CoinPriceView(
                      token: token,
                      balance: assets.assets[assetName],
                      style: context.textTheme.titleMedium,
                    ))
                  ],
                ),
              );
            }),
            // const Divider(),
          ],
        );
      }),
    );
  }
}
