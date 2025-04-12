import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
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
        final asset = _AssetWithPolicyId(
            name: b.key,
            policyID: i.key,
            balance: b.value,
            decimal: b.value.currencyDecimal);
        assets.add(asset);
      }
    }
    return assets;
  }

  late final List<_AssetWithPolicyId> assets;

  Map<_AssetWithPolicyId, IntegerBalance> assetsToTransfer = {};

  void checkAssets() {
    if (!widget.receiver.asset.hasAsset) return;
    for (final i in widget.receiver.asset.assets.entries) {
      for (final b in i.value.assets.entries) {
        final asset = assets.firstWhereOrNull(
            (element) => element.policyID == i.key && element.name == b.key);
        assetsToTransfer[asset]?.updateBalance(b.value.balance);
      }
    }
  }

  void onSelectAsset(
      _AssetWithPolicyId assets, _OnSelectAssets onSelectAssets) async {
    try {
      final r = assetsToTransfer[assets]?.balance ?? BigInt.zero;
      final rAssets = (widget.remindAsset.assets[assets.policyID]
                  ?.assets[assets.name]?.balance ??
              BigInt.zero) +
          r;
      final val = await onSelectAssets(rAssets);
      assetsToTransfer[assets]?.updateBalance(val);
    } finally {
      updateState();
    }
  }

  UtxoMultiAsset toAsset() {
    final Map<PolicyID, UtxoAssets> assets = {};
    for (final i in assetsToTransfer.entries) {
      if (i.value.isZero) continue;
      final UtxoAssets utxoAsset = UtxoAssets({i.key.name: i.value});
      if (assets.containsKey(i.key.policyID)) {
        assets[i.key.policyID] = assets[i.key.policyID]! + utxoAsset;
      } else {
        assets[i.key.policyID] = utxoAsset;
      }
    }
    return UtxoMultiAsset(assets);
  }

  void onSetup() {
    Navigator.of(context).pop(toAsset());
  }

  @override
  void initState() {
    super.initState();
    assets = toAssetsWithPolicyId();
    for (final i in assets) {
      assetsToTransfer[i] =
          IntegerBalance.zero(i.balance.currencyDecimal, allowNegative: false);
    }

    checkAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("setup_output_asset_amount".tr),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onSetup,
        label: Text("setup_recipient_assets".tr),
      ),
      body: CustomScrollView(
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
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReceiptAddressView(
                              address: widget.receiver.address, title: null),
                          ErrorTextContainer(
                              error: "assets_balance_not_supported_desc".tr,
                              enableTap: false),
                        ],
                      )),
                  WidgetConstant.height20,
                  Text("assets".tr, style: context.textTheme.titleMedium),
                  Text("set_amount_for_each_assets_or_zero".tr),
                  WidgetConstant.height8,
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: assets.length,
                    physics: WidgetConstant.noScrollPhysics,
                    separatorBuilder: (context, index) =>
                        WidgetConstant.divider,
                    itemBuilder: (c, index) {
                      final asset = assets[index];
                      return ContainerWithBorder(
                          child: Column(
                        children: [
                          ContainerWithBorder(
                            backgroundColor: context.onPrimaryContainer,
                            child: TokenDetailsWidget(
                              token: asset.token,
                              radius: APPConst.circleRadius25,
                              balance: asset.balance,
                              color: context.primaryContainer,
                            ),
                          ),
                          ContainerWithBorder(
                            backgroundColor: context.onPrimaryContainer,
                            onRemove: () {
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
                                      body: ReceiptAddressView(
                                        address: widget.receiver.address,
                                        title: null,
                                      ),
                                    ),
                                  ),
                                );
                              });
                            },
                            onRemoveIcon: AddOrEditIconWidget(
                              assetsToTransfer[asset]!.largerThanZero,
                              color: context.primaryContainer,
                            ),
                            child: CoinPriceView(
                                token: asset.token,
                                balance: assetsToTransfer[asset],
                                style: context.primaryTextTheme.titleMedium,
                                symbolColor: context.primaryContainer),
                          ),
                        ],
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
          WidgetConstant.sliverPaddingVertial20,
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
