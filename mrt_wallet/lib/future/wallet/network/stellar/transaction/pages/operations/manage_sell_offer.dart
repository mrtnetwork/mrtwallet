import 'package:blockchain_utils/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/utils/stellar/stellar.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/transaction/pages/widgets/pick_asset.dart';
import 'package:mrt_wallet/wallet/constant/networks/stellar.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:stellar_dart/stellar_dart.dart';

class ManageSellOfferOperationView extends StatefulWidget {
  final StellarTransactionStateController controller;
  final StellarManageSellOfferOperation? operation;
  const ManageSellOfferOperationView(
      {required this.controller, this.operation, Key? key})
      : super(key: key);

  @override
  State<ManageSellOfferOperationView> createState() =>
      _ManageSellOfferOperationViewState();
}

class _ManageSellOfferOperationViewState
    extends State<ManageSellOfferOperationView> with SafeState {
  StellarTransactionStateController get controller => widget.controller;
  StellarChain get chain => controller.account;
  StellarPickedIssueAsset? asset;
  StellarPickedIssueAsset? buying;
  bool isReady = false;
  bool showLimit = false;
  BigRational? price;
  String? priceHelper;
  bool get isNative => asset?.asset.type.isNative ?? false;
  late IntegerBalance amount = IntegerBalance.zero(chain.network.coinDecimal);
  BigInt maximumAmount = BigInt.zero;
  BigInt offerId = BigInt.zero;
  late final IntegerBalance remindAmount =
      IntegerBalance.zero(chain.network.coinDecimal);

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
    buying = null;
    price = null;
    priceHelper = null;
    showLimit = this.asset != null;
    remindAmount.zero();
    amount.zero();
    calculateMaximumAmount();
    calculateRemindAmount();
    checkIsReady();
    updateState();
  }

  void pickDestAssets(StellarPickedIssueAsset? buying) {
    if (buying == null) return;
    if (buying.asset == asset?.asset) {
      context.showAlert("different_selling_from_buying_validator_desc".tr);
      return;
    }
    this.buying = buying;
    price = null;
    priceHelper = null;
    calculateMaximumAmount();
    calculateMaximumAmount();
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

  void setupOperation() {
    if (!isReady) return;
    final operation = StellarManageSellOfferOperation(
        asset: asset!,
        amount: amount,
        buying: buying!,
        offerId: offerId,
        price: StellarPrice.fromDecimal(price!.toDecimal()));
    context.pop(operation);
  }

  void checkIsReady() {
    isReady = !amount.isNegative &&
        !remindAmount.isNegative &&
        buying != null &&
        asset != null &&
        price != null;
  }

  void onChangePrice(BigRational? rational) {
    price = rational;
    if (price == null) {
      priceHelper = null;
    } else {
      priceHelper = "exchange_entred_price_desc"
          .tr
          .replaceOne(PriceUtils.priceWithCoinName(
              price!.toDecimal(), buying!.token.symbol))
          .replaceTwo(asset!.token.symbol);
    }
    checkIsReady();
    updateState();
  }

  void onChangeOfferId(BigRational? offerId) {
    final offerIdBigInt = StellarUtils.tryRationalNumberToOfferId(offerId);
    if (offerIdBigInt == null) return;
    this.offerId = offerIdBigInt;
    checkIsReady();
    updateState();
  }

  void init() {
    final operation = widget.operation;
    if (operation == null) return;
    asset = operation.asset;
    buying = operation.buying;
    amount.updateBalance(operation.amount.balance);
    showLimit = asset != null;
    price = operation.price.toBigRational();
    priceHelper = "exchange_entred_price_desc"
        .tr
        .replaceOne(PriceUtils.priceWithCoinName(
            price!.toDecimal(), buying!.token.symbol))
        .replaceTwo(asset!.token.symbol);
    offerId = operation.offerId;
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
            title: "stellar_manage_sell_offer".tr,
            body: LargeTextView([
              "stellar_manage_sell_offer_desc".tr,
              if (widget.operation != null) ...[
                "remove_operation_close_page_desc".tr,
              ]
            ])),
        Text("selling".tr, style: context.textTheme.titleMedium),
        Text("stellar_manage_sell_offer_selling".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: asset != null,
          iconAlginment: asset == null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
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
                        onTapWhenOnRemove: false,
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
  final _ManageSellOfferOperationViewState state;
  const _Amount(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransactionAmountView(
          amount: state.amount,
          token: state.asset!.token,
          title: "amount".tr,
          subtitle: "stellar_manage_sell_offer_amount".tr,
          onTap: () {
            context
                .openSliverBottomSheet<BigInt>(
                  "amount".tr,
                  child: SetupNetworkAmount(
                    buttonText: "setup_amount".tr,
                    token: state.asset!.token,
                    max: state.maximumAmount,
                    subtitleText: "stellar_manage_sell_offer_amount".tr,
                    min: BigInt.zero,
                  ),
                )
                .then(state.setupAmount);
          },
        ),
        WidgetConstant.height20,
        Text("buying".tr, style: context.textTheme.titleMedium),
        LargeTextView(["stellar_manage_sell_offer_buying".tr], maxLine: 2),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: state.buying != null,
          iconAlginment: state.buying == null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          onRemoveIcon: state.buying == null
              ? const Icon(Icons.add_box)
              : const Icon(Icons.edit),
          child: state.buying == null
              ? Text("tap_to_select_or_create_asset".tr)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.buying!.asset.type.name,
                        style: context.colors.onPrimaryContainer
                            .lableLarge(context)),
                    OneLineTextWidget(state.buying!.issuer ?? '',
                        style: context.colors.onPrimaryContainer
                            .bodyMedium(context)),
                    ContainerWithBorder(
                      backgroundColor: context.colors.onPrimaryContainer,
                      onTapWhenOnRemove: false,
                      child: TokenDetailsWidget(
                        token: state.buying!.token,
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
        APPAnimatedSwitcher(enable: state.buying == null, widgets: {
          false: (c) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetConstant.height20,
                  Text("price".tr, style: context.textTheme.titleMedium),
                  Text("stellar_manage_sell_offer_price".tr),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      onRemoveIcon: Icon(Icons.edit,
                          color: context.colors.onPrimaryContainer),
                      child: state.price == null
                          ? Text("tap_to_setup_price".tr)
                          : Row(
                              children: [
                                Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    CircleTokenImageView(state.asset!.token,
                                        radius: APPConst.iconSize),
                                    Container(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: CircleTokenImageView(
                                          state.buying!.token,
                                          radius: APPConst.iconSize),
                                    ),
                                  ],
                                ),
                                WidgetConstant.width8,
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(state.price!.toDecimal(),
                                        style: context.colors.onPrimaryContainer
                                            .lableLarge(context)),
                                    Text(
                                      state.priceHelper ?? '',
                                      style: context.colors.onPrimaryContainer
                                          .bodyMedium(context),
                                    ),
                                  ],
                                )),
                              ],
                            ),
                      onRemove: () {
                        context
                            .openSliverBottomSheet<BigRational>(
                                "setup_price".tr,
                                child: SetupDecimalExchangeRateInput(
                                  tokenA: state.buying!.token,
                                  tokenB: state.asset!.token,
                                  buttonText: "setup_price".tr,
                                  maxScale: StellarConst.decimal,
                                  isBuy: false,
                                  min: BigRational.zero,
                                  max: StellarConst.maxIssueAmountRational,
                                  subtitle: PageTitleSubtitle(
                                      title: "price".tr,
                                      body: Text(
                                          "stellar_manage_sell_offer_price"
                                              .tr)),
                                ))
                            .then(state.onChangePrice);
                      }),
                  WidgetConstant.height20,
                  Text("offer_id".tr, style: context.textTheme.titleMedium),
                  LargeTextView(["stellar_manage_sell_offer_offer_id".tr]),
                  WidgetConstant.height8,
                  ContainerWithBorder(
                      onRemoveIcon: Icon(Icons.edit,
                          color: context.colors.onPrimaryContainer),
                      child: Text(
                        state.offerId.toString(),
                        style: context.colors.onPrimaryContainer
                            .bodyMedium(context),
                      ),
                      onRemove: () {
                        context
                            .openSliverBottomSheet<BigRational>(
                                "setup_offer_id".tr,
                                child: NumberWriteView(
                                    title: PageTitleSubtitle(
                                        title: "offer_id".tr,
                                        body: Text(
                                            "stellar_manage_sell_offer_offer_id"
                                                .tr)),
                                    label: "offer_id".tr,
                                    buttonText: "setup_offer_id".tr,
                                    allowDecimal: false,
                                    allowSign: false,
                                    defaultValue: BigRational(state.offerId),
                                    max: StellarConst.maxIssueAmountRational,
                                    min: BigRational.zero))
                            .then(state.onChangeOfferId);
                      })
                ],
              )
        }),
        InsufficientBalanceErrorView(
          verticalMargin: WidgetConstant.paddingVertical10,
          balance: state.remindAmount,
          token: state.asset!.token,
        ),
      ],
    );
  }
}
