import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/transaction/pages/widgets/pick_asset.dart';
import 'package:mrt_wallet/wallet/constant/networks/stellar.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/networks/stellar/stellar.dart';

class ChangeTrustOperationView extends StatefulWidget {
  final StellarTransactionStateController controller;
  final StellarChangeTrustOperation? operation;
  const ChangeTrustOperationView(
      {required this.controller, this.operation, Key? key})
      : super(key: key);

  @override
  State<ChangeTrustOperationView> createState() =>
      _ChangeTrustOperationViewState();
}

class _ChangeTrustOperationViewState extends State<ChangeTrustOperationView>
    with SafeState {
  StellarTransactionStateController get controller => widget.controller;
  StellarChain get chain => controller.account;
  StellarPickedIssueAsset? asset;
  late IntegerBalance limit = IntegerBalance.zero(chain.network.coinDecimal);
  void pickAssets(StellarPickedIssueAsset? asset) {
    if (asset == null || asset.asset.type.isNative) return;
    this.asset = asset;
    showLimit = this.asset != null;
    limit.updateBalance(BigInt.zero);
    updateState();
  }

  void setupAmount(BigInt? amount) {
    if (amount == null) return;
    limit.updateBalance(amount);
    updateState();
  }

  void setupOperation() {
    if (asset == null) return;
    final operation = StellarChangeTrustOperation(asset: asset!, limit: limit);
    context.pop(operation);
  }

  bool showLimit = false;

  void init() {
    final operation = widget.operation;
    if (operation == null) return;
    asset = operation.asset;
    limit.updateBalance(operation.limit.balance);
    showLimit = asset != null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "change_trust".tr,
            body: LargeTextView([
              "change_trust_desc".tr,
              "stellar_change_trust_limit_zero_desc".tr,
              if (widget.operation != null)
                "remove_operation_close_page_desc".tr
            ])),
        Text("asset".tr, style: context.textTheme.titleMedium),
        Text("modify_trust_line_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemoveIcon: asset == null
              ? Icon(
                  Icons.add_box,
                  color: context.colors.onPrimaryContainer,
                )
              : Icon(
                  Icons.edit,
                  color: context.colors.onPrimaryContainer,
                ),
          child: asset == null
              ? Text("tap_to_select_or_create_asset".tr)
              : TokenDetailsWidget(token: asset!.token),
          onRemove: () {
            context
                .openSliverDialog<StellarPickedIssueAsset>(
                    (c) => PickFromAccountAssets(
                          accountInfo: controller.accountInfo,
                          chain: chain,
                          allowNativeAssets: false,
                        ),
                    "assets".tr,
                    content: (c) => [
                          IconButton(
                            tooltip: "create_assets".tr,
                            icon: const Icon(Icons.add_box),
                            onPressed: () {
                              c.pop();
                              context
                                  .openSliverBottomSheet<
                                          StellarPickedIssueAsset>(
                                      "pick_an_asset".tr,
                                      initialExtend: 1,
                                      child: StellarPickAssetView(chain: chain))
                                  .then(pickAssets);
                            },
                          )
                        ])
                .then(pickAssets);
          },
        ),
        WidgetConstant.height20,
        APPAnimatedSwitcher<bool>(
            enable: showLimit, widgets: {true: (c) => _ChangeTrustLimit(this)}),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FixedElevatedButton(
              padding: WidgetConstant.paddingVertical40,
              onPressed: asset != null ? setupOperation : null,
              child: Text("setup_operation".tr))
        ])
      ],
    );
  }
}

class _ChangeTrustLimit extends StatelessWidget {
  final _ChangeTrustOperationViewState state;
  const _ChangeTrustLimit(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("limit".tr, style: context.textTheme.titleMedium),
        Text("change_trust_limit".tr),
        Text("stellar_change_trust_limit_zero_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: !state.limit.isNegative,
          onRemoveIcon:
              Icon(Icons.edit, color: context.colors.onPrimaryContainer),
          child: CoinPriceView(
            token: state.asset!.token,
            balance: state.limit,
            style: context.colors.onPrimaryContainer.titleLarge(context),
            symbolColor: context.colors.onPrimaryContainer,
            showTokenImage: true,
          ),
          onRemove: () {
            context
                .openSliverBottomSheet<BigInt>(
                  "limit".tr,
                  child: SetupNetworkAmount(
                    buttonText: "setup_amount".tr,
                    token: state.asset!.token,
                    max: StellarConst.maxIssueAmount,
                    min: BigInt.zero,
                  ),
                )
                .then(state.setupAmount);
          },
        )
      ],
    );
  }
}
