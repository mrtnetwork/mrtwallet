import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/transaction/pages/widgets/pick_asset.dart';
import 'package:mrt_wallet/wallet/api/client/networks/stellar/stellar.dart';
import 'package:mrt_wallet/wallet/constant/networks/stellar.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'operation_destination_tracker.dart';

class PathPaymentStrictSendOperationView extends StatefulWidget {
  final StellarTransactionStateController controller;
  final StellarPathPaymentStrictSendOperation? operation;
  const PathPaymentStrictSendOperationView(
      {required this.controller, this.operation, Key? key})
      : super(key: key);

  @override
  State<PathPaymentStrictSendOperationView> createState() =>
      _PathPaymentStrictSendOperationViewState();
}

class _PathPaymentStrictSendOperationViewState
    extends State<PathPaymentStrictSendOperationView>
    with SafeState, StellarOperationDestinationTracker {
  StellarTransactionStateController get controller => widget.controller;
  StellarChain get chain => controller.account;
  StellarPickedIssueAsset? asset;
  StellarPickedIssueAsset? destAssets;
  bool get isNative => asset?.asset.type.isNative ?? false;
  late IntegerBalance amount = IntegerBalance.zero(chain.network.coinDecimal);
  late IntegerBalance destMin = IntegerBalance.zero(chain.network.coinDecimal);
  @override
  late final StellarClient client = chain.provider()!;
  BigInt maximumAmount = BigInt.zero;
  late final IntegerBalance remindAmount =
      IntegerBalance.zero(chain.network.coinDecimal);
  List<StellarPickedIssueAsset> paths = [];
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

  StellarIssueToken? findToken() {
    final asset = this.asset;
    if (asset == null || asset.asset.type.isNative) {
      return null;
    }
    final inAccount = controller.accountInfo.getAsset(asset.asset);
    if (inAccount != null) {
      StellarIssueToken? token = chain.address.tokens.firstWhere(
          (e) =>
              e.issuer == inAccount.assetIssuer &&
              e.token.symbol == inAccount.assetCode,
          orElse: () => inAccount.toIssueToken());
      return token;
    }
    return null;
  }

  void pickAssets(StellarPickedIssueAsset? asset) {
    if (asset == null) return;
    this.asset = asset;
    showLimit = this.asset != null;
    remindAmount.zero();
    amount.zero();
    calculateMaximumAmount();
    calculateRemindAmount();
    checkIsReady();
    updateState();
  }

  void pickDestAssets(StellarPickedIssueAsset? destAssets) {
    if (destAssets == null) return;
    this.destAssets = destAssets;
    destMin.zero();
    calculateMaximumAmount();
    calculateRemindAmount();
    checkIsReady();
    updateState();
  }

  void setupAmount(BigInt? amount) {
    if (amount == null) return;
    this.amount.updateBalance(amount);
    calculateRemindAmount();
    checkIsReady();
    updateState();
  }

  void addToPathList(StellarPickedIssueAsset? path) {
    if (path == null) return;
    if (paths.length >= 5) {
      return;
    }
    final hasAny = paths.any((e) => e.asset == path.asset);
    if (hasAny || destAssets?.asset == path.asset) {
      context.showAlert("path_already_exist".tr);
      return;
    }
    paths.add(path);
    updateState();
  }

  void removeFromPathList(StellarPickedIssueAsset path) {
    paths.remove(path);
    updateState();
  }

  void stupDestAmount(BigInt? amount) {
    if (amount == null) return;
    destMin.updateBalance(amount);
    updateState();
  }

  void setupOperation() {
    if (!isReady) return;
    final operation = StellarPathPaymentStrictSendOperation(
        asset: asset!,
        sendAmount: amount,
        destination: receiver!,
        destMin: destMin,
        destAsset: destAssets!,
        paths: paths);
    context.pop(operation);
  }

  void checkIsReady() {
    isReady = asset != null &&
        receiver != null &&
        !amount.isNegative &&
        !remindAmount.isNegative &&
        destAssets != null &&
        !destMin.isNegative;
  }

  void init() {
    final operation = widget.operation;
    if (operation == null) return;
    receiver = operation.destination;
    trackActivity(receiver!);
    asset = operation.asset;
    destAssets = operation.destAsset;
    amount.updateBalance(operation.sendAmount.balance);
    destMin.updateBalance(operation.destMin.balance);
    paths.addAll(operation.paths);
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
            title: "stellar_path_payment_strict_send".tr,
            body: LargeTextView([
              "stellar_path_payment_strict_send_desc".tr,
              if (widget.operation != null) ...[
                "remove_operation_close_page_desc".tr,
              ]
            ])),
        Text("send_asset".tr, style: context.textTheme.titleMedium),
        Text("stellar_path_send_send_asset_desc".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: asset != null,
          iconAlginment: asset == null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          onRemoveIcon: asset == null
              ? Icon(Icons.add_box, color: context.colors.onPrimaryContainer)
              : Icon(Icons.edit, color: context.colors.onPrimaryContainer),
          child: asset == null
              ? Text("tap_to_select_or_create_asset".tr)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (asset!.asset.type.isNative) ...[
                      Text(asset!.asset.type.name,
                          style: context.colors.onPrimaryContainer
                              .lableLarge(context)),
                      WidgetConstant.height8,
                      ContainerWithBorder(
                        backgroundColor: context.colors.onPrimaryContainer,
                        child: TokenDetailsWidget(
                          token: asset!.token,
                          liveBalance: chain.address.address.balance,
                          color: context.colors.primaryContainer,
                        ),
                      )
                    ] else ...[
                      Text(asset!.asset.type.name,
                          style: context.colors.onPrimaryContainer
                              .lableLarge(context)),
                      OneLineTextWidget(asset!.issuer ?? '',
                          style: context.colors.onPrimaryContainer
                              .bodyMedium(context)),
                      ContainerWithBorder(
                        backgroundColor: context.colors.onPrimaryContainer,
                        child: TokenDetailsWidget(
                          token: asset!.currentToken,
                          balance: asset?.tokenBalance,
                          color: context.colors.primaryContainer,
                        ),
                      ),
                    ]
                  ],
                ),
          onRemove: () {
            context
                .openSliverDialog<StellarPickedIssueAsset>(
                    (c) => PickFromAccountAssets(
                        accountInfo: controller.accountInfo, chain: chain),
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
  final _PathPaymentStrictSendOperationViewState state;
  const _Amount(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransactionAmountView(
          amount: state.amount,
          token: state.asset!.token,
          title: "send_amount".tr,
          subtitle: "stellar_path_receive_send_amount_desc".tr,
          onTap: () {
            context
                .openSliverBottomSheet<BigInt>(
                  "send_amount".tr,
                  child: SetupNetworkAmount(
                    buttonText: "setup_amount".tr,
                    token: state.asset!.token,
                    max: state.maximumAmount,
                    subtitleText: "stellar_path_receive_send_amount_desc".tr,
                    min: BigInt.zero,
                  ),
                )
                .then(state.setupAmount);
          },
        ),
        WidgetConstant.height20,
        ReceiptAddressView(
          onTapWhenOnRemove: state.receiver == null,
          title: "destination".tr,
          subtitle: "stellar_path_send_destination_desc".tr,
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
                                  "destination".tr,
                                  bodyBuilder: (c) =>
                                      SelectRecipientAccountView<
                                          StellarAddress>(
                                        account: state.chain,
                                        scrollController: c,
                                        subtitle: PageTitleSubtitle(
                                            title: "destination".tr,
                                            body: Text(
                                                "stellar_path_send_destination_desc"
                                                    .tr)),
                                      ))
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
                    "destination".tr,
                    bodyBuilder: (c) =>
                        SelectRecipientAccountView<StellarAddress>(
                          account: state.chain,
                          scrollController: c,
                          subtitle: PageTitleSubtitle(
                              title: "destination".tr,
                              body: Text(
                                  "stellar_path_send_destination_desc".tr)),
                        ))
                .then(state.setReceiver);
          },
        ),
        WidgetConstant.height20,
        Text("destination_asset".tr, style: context.textTheme.titleMedium),
        LargeTextView(["stellar_path_send_dest_asset_desc".tr], maxLine: 2),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: state.destAssets != null,
          iconAlginment: state.destAssets == null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          onRemoveIcon: state.destAssets == null
              ? Icon(Icons.add_box, color: context.colors.onPrimaryContainer)
              : Icon(Icons.edit, color: context.colors.onPrimaryContainer),
          child: state.destAssets == null
              ? Text("tap_to_select_or_create_asset".tr)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.destAssets!.asset.type.name,
                        style: context.colors.onPrimaryContainer
                            .lableLarge(context)),
                    OneLineTextWidget(state.destAssets!.issuer ?? '',
                        style: context.colors.onPrimaryContainer
                            .bodyMedium(context)),
                    ContainerWithBorder(
                      backgroundColor: context.colors.onPrimaryContainer,
                      child: TokenDetailsWidget(
                        token: state.destAssets!.token,
                        radius: APPConst.iconSize,
                        color: context.colors.primaryContainer,
                      ),
                    ),
                  ],
                ),
          onRemove: () {
            context
                .openSliverDialog<StellarPickedIssueAsset>(
                    (c) => PickFromAccountAssets(
                        accountInfo: state.controller.accountInfo,
                        chain: state.chain),
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
                                      child: StellarPickAssetView(
                                          chain: state.chain))
                                  .then(state.pickDestAssets);
                            },
                          )
                        ])
                .then(state.pickDestAssets);
          },
        ),
        APPAnimatedSwitcher(enable: state.destAssets == null, widgets: {
          false: (c) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetConstant.height20,
                  TransactionAmountView(
                    amount: state.destMin,
                    token: state.destAssets!.token,
                    title: "minimum_destination_amount".tr,
                    subtitle: "stellar_path_send_dest_min_desc".tr,
                    onTap: () {
                      context
                          .openSliverBottomSheet<BigInt>(
                            "minimum_destination_amount".tr,
                            child: SetupNetworkAmount(
                                buttonText: "setup_amount".tr,
                                token: state.destAssets!.token,
                                subtitleText:
                                    "stellar_path_send_dest_min_desc".tr,
                                max: StellarConst.maxIssueAmount,
                                min: BigInt.zero),
                          )
                          .then(state.stupDestAmount);
                    },
                  ),
                  WidgetConstant.height20,
                  Text("path".tr, style: context.textTheme.titleMedium),
                  LargeTextView(["stellar_path_send_path_desc".tr], maxLine: 2),
                  WidgetConstant.height8,
                  ...List.generate(state.paths.length, (index) {
                    final asset = state.paths.elementAt(index);
                    return ContainerWithBorder(
                      onRemoveIcon: Icon(Icons.remove_circle,
                          color: context.colors.onPrimaryContainer),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(asset.asset.type.name,
                              style: context.colors.onPrimaryContainer
                                  .lableLarge(context)),
                          if (asset.issuer != null)
                            OneLineTextWidget(asset.issuer ?? '',
                                style: context.colors.onPrimaryContainer
                                    .bodyMedium(context)),
                          ContainerWithBorder(
                            backgroundColor: context.colors.onPrimaryContainer,
                            onTapWhenOnRemove: false,
                            child: TokenDetailsWidget(
                              token: asset.token,
                              radius: APPConst.iconSize,
                              color: context.colors.primaryContainer,
                            ),
                          ),
                        ],
                      ),
                      onRemove: () {
                        state.removeFromPathList(asset);
                      },
                    );
                  }),
                  APPAnimatedSwitcher<
                      bool>(enable: state.paths.length < 5, widgets: {
                    true: (c) => ContainerWithBorder(
                          onRemoveIcon: Icon(Icons.add_box,
                              color: context.colors.onPrimaryContainer),
                          child: Text("tap_to_select_or_create_asset".tr),
                          onRemove: () {
                            context
                                .openSliverDialog<StellarPickedIssueAsset>(
                                    (c) => PickFromAccountAssets(
                                        accountInfo:
                                            state.controller.accountInfo,
                                        chain: state.chain),
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
                                                      child:
                                                          StellarPickAssetView(
                                                              chain:
                                                                  state.chain))
                                                  .then(state.addToPathList);
                                            },
                                          )
                                        ])
                                .then(state.addToPathList);
                          },
                        ),
                  })
                ],
              )
        }),
        InsufficientBalanceErrorView(
          verticalMargin: WidgetConstant.paddingVertical10,
          balance: state.remindAmount,
          token: state.asset!.token,
        ),
        ErrorTextContainer(
            margin: WidgetConstant.paddingVertical10,
            error: state.destinationInactiveError),
      ],
    );
  }
}
