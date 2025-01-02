import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/app.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/transaction/pages/widgets/pick_asset.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:stellar_dart/stellar_dart.dart';

import 'operation_destination_tracker.dart';

class PaymentOperationView extends StatefulWidget {
  final StellarTransactionStateController controller;
  final StellarPaymentOperation? operation;
  const PaymentOperationView(
      {required this.controller, this.operation, super.key});

  @override
  State<PaymentOperationView> createState() => _PaymentOperationViewState();
}

class _PaymentOperationViewState extends State<PaymentOperationView>
    with SafeState, StellarOperationDestinationTracker {
  StellarTransactionStateController get controller => widget.controller;
  StellarChain get chain => controller.account;
  @override
  StellarClient get client => chain.client;
  @override
  StellarPickedIssueAsset? asset;
  bool get isNative => asset?.asset.type.isNative ?? false;
  late IntegerBalance amount = IntegerBalance.zero(chain.network.coinDecimal);
  BigInt maximumAmount = BigInt.zero;
  late final IntegerBalance remindAmount =
      IntegerBalance.zero(chain.network.coinDecimal);
  bool isReady = false;
  bool showLimit = false;

  void calculateMaximumAmount() {
    assert(asset != null, "asset should not be null.");
    final sameOperations = controller.customOperations
        .where((e) => e.asset?.asset == asset?.asset && e != widget.operation);
    final totalStroop = sameOperations.fold(BigInt.zero, (p, c) => p + c.value);
    if (isNative) {
      maximumAmount = chain.address.address.currencyBalance -
          (totalStroop + (controller.fee?.balance ?? BigInt.zero));
      return;
    }
    if (asset!.tokenBalance == null) {
      maximumAmount = StellarConst.maxIssueAmount;
    } else {
      maximumAmount = asset!.tokenBalance!.balance - totalStroop;
    }
  }

  void calculateRemindAmount() {
    assert(asset != null, "asset should not be null.");
    final remind = maximumAmount - amount.balance;
    remindAmount.updateBalance(remind);
  }

  void pickAssets(StellarPickedIssueAsset? asset) {
    if (asset == null) return;
    this.asset = asset;
    showLimit = this.asset != null;
    remindAmount.zero();
    amount.zero();
    calculateMaximumAmount();
    calculateRemindAmount();
    checkTrustPathLimit(asset, amount.balance);
    checkIsReady();
    updateState();
  }

  void setupAmount(BigInt? amount) {
    if (amount == null) return;
    this.amount.updateBalance(amount);
    calculateRemindAmount();
    checkIsReady();
    checkTrustPathLimit(asset, this.amount.balance);
  }

  @override
  void onAccountActivityUpdated() {
    checkTrustPathLimit(asset, amount.balance);
  }

  void setupOperation() {
    if (!isReady) return;
    final operation = StellarPaymentOperation(
        asset: asset!, amount: amount, destination: receiver!);
    context.pop(operation);
  }

  void checkIsReady() {
    isReady =
        receiver != null && !amount.isNegative && !remindAmount.isNegative;
  }

  void init() {
    final operation = widget.operation;
    if (operation == null) return;
    receiver = operation.destination;
    asset = operation.asset;
    amount.updateBalance(operation.amount.balance);
    showLimit = asset != null;
    calculateMaximumAmount();
    calculateRemindAmount();
    checkIsReady();
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
            title: "payment".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("stellar_payment_desc".tr),
                if (widget.operation != null) ...[
                  WidgetConstant.height8,
                  Text("remove_operation_close_page_desc".tr),
                ]
              ],
            )),
        Text("asset".tr, style: context.textTheme.titleMedium),
        Text("select_stellar_payment_assets_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemoveIcon: AddOrEditIconWidget(asset != null),
          child: ConditionalWidget(
            onActive: (context) {
              return Row(
                children: [
                  Expanded(
                    child: TokenDetailsWidget(
                      token: asset!.asset.type.isNative
                          ? asset!.token
                          : asset!.currentToken,
                      balance: asset!.asset.type.isNative
                          ? chain.address.address.balance.value
                          : asset?.tokenBalance,
                      tokenAddress: asset!.issuer,
                      color: context.onPrimaryContainer,
                      radius: APPConst.circleRadius25,
                    ),
                  ),
                  if (!asset!.asset.type.isNative &&
                      asset?.issueToken == null) ...[
                    WidgetConstant.width8,
                    TappedTooltipView(
                      tooltipWidget: ToolTipView(
                          message: "stellar_new_token_created".tr,
                          child: Icon(Icons.warning,
                              color: context.colors.tertiary)),
                    )
                  ]
                ],
              );
            },
            enable: asset != null,
            onDeactive: (context) => Text(
              "tap_to_select_or_create_asset".tr,
              style: context.onPrimaryTextTheme.bodyMedium,
            ),
          ),
          onRemove: () {
            context
                .openSliverDialog<StellarPickedIssueAsset>(
                    (c) => PickFromAccountAssets(
                        accountInfo: controller.accountInfo, chain: chain),
                    "assets".tr,
                    content: (context) => [
                          IconButton(
                            tooltip: "create_assets".tr,
                            icon: const Icon(Icons.add_box),
                            onPressed: () {
                              context.pop();
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
            enable: showLimit, widgets: {true: (c) => _Amount(this)}),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FixedElevatedButton(
              padding: WidgetConstant.paddingVertical40,
              onPressed: isReady ? setupOperation : null,
              child: Text("setup_operation".tr))
        ])
      ],
    );
  }
}

class _Amount extends StatelessWidget {
  final _PaymentOperationViewState state;
  const _Amount(this.state);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptAddressView(
          enableTap: state.receiver == null,
          address: state.receiver?.address,
          onEditWidget: state.receiver == null
              ? null
              : Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          context
                              .openSliverBottomSheet<
                                      ReceiptAddress<StellarAddress>>(
                                  "receiver_address".tr,
                                  bodyBuilder: (c) =>
                                      SelectRecipientAccountView<
                                              StellarAddress>(
                                          account: state.chain,
                                          scrollController: c),
                                  maxExtend: 1,
                                  minExtent: 0.8,
                                  initialExtend: 0.9)
                              .then(state.setReceiver);
                        },
                        icon: Icon(Icons.edit,
                            color: context.colors.onPrimaryContainer)),
                    IconButton(
                        tooltip: state.receiver!.status.message?.tr,
                        onPressed: () {
                          state.trackActivity(state.receiver!);
                        },
                        icon: StatusIconWidget(
                          status: state.receiver!.status.toProgressStatus,
                          size: APPConst.iconSize,
                          onSuccessIcon: state.receiver!.status.isInactive
                              ? Icon(Icons.no_accounts_rounded,
                                  color: context.colors.onPrimaryContainer)
                              : Icon(Icons.account_circle,
                                  color: context.colors.onPrimaryContainer),
                        ))
                  ],
                ),
          onTap: () {
            context
                .openSliverBottomSheet<ReceiptAddress<StellarAddress>>(
                    "receiver_address".tr,
                    bodyBuilder: (c) =>
                        SelectRecipientAccountView<StellarAddress>(
                            account: state.chain, scrollController: c),
                    maxExtend: 1,
                    minExtent: 0.8,
                    initialExtend: 0.9)
                .then(state.setReceiver);
          },
        ),
        WidgetConstant.height20,
        TransactionAmountView(
          amount: state.amount,
          token: state.asset!.token,
          onTap: () {
            context
                .openSliverBottomSheet<BigInt>(
                  "setup_output_amount".tr,
                  initialExtend: 1,
                  child: SetupNetworkAmount(
                    buttonText: "setup_amount".tr,
                    token: state.asset!.token,
                    max: state.maximumAmount,
                    subtitle: state.receiver == null
                        ? null
                        : PageTitleSubtitle(
                            title: "receiver".tr,
                            body: ContainerWithBorder(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OneLineTextWidget(state.receiver!.address.view)
                              ],
                            ))),
                    min: BigInt.zero,
                  ),
                )
                .then(state.setupAmount);
          },
        ),
        InsufficientBalanceErrorView(
          verticalMargin: WidgetConstant.paddingVertical10,
          balance: state.remindAmount,
          token: state.asset!.token,
        ),
        ErrorTextContainer(
            margin: WidgetConstant.paddingVertical10,
            error: state.destinationInactiveError ?? state.pathLimitError),
      ],
    );
  }
}
