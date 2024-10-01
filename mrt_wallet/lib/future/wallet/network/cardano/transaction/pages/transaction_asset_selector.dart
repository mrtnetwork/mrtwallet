import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/future/wallet/global/pages/setup_amount.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

typedef _OnSelectAssets = Future<BigInt?> Function(BigInt? value);

class CardanoTransactionAssetSelectorView extends StatefulWidget {
  const CardanoTransactionAssetSelectorView(
      {super.key,
      required this.totalAssets,
      required this.remindAsset,
      required this.receiver,
      required this.controller});
  final UtxoMultiAsset totalAssets;
  final UtxoMultiAsset remindAsset;
  final CardanoOutputWithBalance receiver;
  final ScrollController controller;

  @override
  State<CardanoTransactionAssetSelectorView> createState() =>
      _CardanoTransactionAssetSelectorViewState();
}

class _CardanoTransactionAssetSelectorViewState
    extends State<CardanoTransactionAssetSelectorView> with SafeState {
  List<_AssetWithPolicyId> toAssetsWithPolicyId() {
    final List<_AssetWithPolicyId> assets = [];
    for (final i in widget.totalAssets.assets.entries) {
      for (final b in i.value.assets.entries) {
        assets.add(_AssetWithPolicyId(
            name: b.key,
            policyID: i.key,
            balance: b.value,
            decimal: b.value.currencyDecimal));
      }
    }
    return assets;
  }

  late final List<_AssetWithPolicyId> assets = toAssetsWithPolicyId();

  Map<_AssetWithPolicyId, IntegerBalance> assetsToTransfer = {};

  void checkAssets() {
    if (!widget.receiver.asset.hasAsset) return;
    for (final i in widget.receiver.asset.assets.entries) {
      for (final b in i.value.assets.entries) {
        try {
          final a = assets.firstWhere(
              (element) => element.policyID == i.key && element.name == b.key);
          assetsToTransfer[a] =
              IntegerBalance(b.value.balance, b.value.currencyDecimal);
        } on StateError {
          continue;
        }
      }
    }
  }

  void onSelectAsset(
      _AssetWithPolicyId assets, _OnSelectAssets onSelectAssets) async {
    try {
      final r = assetsToTransfer.remove(assets);
      final rAssets = (widget.remindAsset.assets[assets.policyID]
                  ?.assets[assets.name]?.balance ??
              BigInt.zero) +
          (r?.balance ?? BigInt.zero);
      final val = await onSelectAssets(
          rAssets + (assetsToTransfer[assets]?.balance ?? BigInt.zero));
      if (val == null || val <= BigInt.zero) return;
      assetsToTransfer[assets] = IntegerBalance(val, assets.decimal);
    } finally {
      setState(() {});
    }
  }

  UtxoMultiAsset toAsset() {
    final Map<PolicyID, UtxoAssets> assets = {};
    for (final i in assetsToTransfer.entries) {
      final UtxoAssets utxoAsset = UtxoAssets({i.key.name: i.value});
      if (assets.containsKey(i.key.policyID)) {
        assets[i.key.policyID] = assets[i.key.policyID]! + utxoAsset;
      } else {
        assets[i.key.policyID] = utxoAsset;
      }
    }
    return UtxoMultiAsset(assets);
  }

  void onSetuo() {
    if (context.mounted) {
      Navigator.of(context).pop(toAsset());
    }
  }

  @override
  void initState() {
    super.initState();
    checkAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("setup_output_asset_amount".tr),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: widget.controller,
              slivers: [
                SliverToBoxAdapter(
                  child: ConstraintsBoxView(
                    padding: WidgetConstant.padding20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PageTitleSubtitle(
                            title: "receiver".tr,
                            body: ContainerWithBorder(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    widget.receiver.address.networkAddress
                                        .addressType.name,
                                    style: context.textTheme.labelLarge),
                                OneLineTextWidget(widget.receiver.address.view)
                              ],
                            ))),
                        WidgetConstant.height20,
                        Text("choose_asset_you_want_to_transfer".tr,
                            style: context.textTheme.titleMedium),
                        WidgetConstant.height8,
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: assets.length,
                          physics: WidgetConstant.noScrollPhysics,
                          itemBuilder: (c, index) {
                            final asset = assets[index];
                            return ContainerWithCheckBoxAndBorder(
                              value: assetsToTransfer.containsKey(asset),
                              onChange: (p0) {
                                onSelectAsset(asset, (max) async {
                                  return await context
                                      .openSliverBottomSheet<BigInt>(
                                    "setup_output_amount".tr,
                                    child: SetupNetworkAmount(
                                      token: asset.token,
                                      max: max,
                                      min: BigInt.zero,
                                      subtitle: PageTitleSubtitle(
                                          title: "receiver".tr,
                                          body: ContainerWithBorder(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  widget
                                                      .receiver
                                                      .address
                                                      .networkAddress
                                                      .addressType
                                                      .name,
                                                  style: context
                                                      .textTheme.labelLarge),
                                              OneLineTextWidget(
                                                  widget.receiver.address.view)
                                            ],
                                          ))),
                                    ),
                                  );
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleTokenImageView(
                                        asset.token,
                                        radius: APPConst.circleRadius25,
                                      ),
                                      WidgetConstant.width8,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(asset.token.nameView,
                                                maxLines: 1,
                                                style: context
                                                    .textTheme.labelLarge),
                                            if (assetsToTransfer
                                                .containsKey(asset)) ...[
                                              CoinPriceView(
                                                token: asset.token,
                                                balance:
                                                    assetsToTransfer[asset],
                                                style: context
                                                    .textTheme.titleMedium,
                                              )
                                            ]
                                          ],
                                        ),
                                      ),
                                      CoinPriceView(
                                          token: asset.token,
                                          balance: asset.balance,
                                          style: context.textTheme.titleMedium)
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: WidgetConstant.paddingVertical20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: onSetuo, child: Text("setup_output_amount".tr))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _AssetWithPolicyId {
  final AssetName name;
  final IntegerBalance balance;
  final PolicyID policyID;
  final int decimal;
  late final Token token =
      Token(name: name.name, symbol: name.name, decimal: decimal);
  _AssetWithPolicyId(
      {required this.name,
      required this.policyID,
      required this.balance,
      required this.decimal});
}
