import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/networks/cosmos/models/transaction_output.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';

class CosmosSetTransferFeeView extends StatefulWidget {
  const CosmosSetTransferFeeView({required this.fee, super.key});
  final CosmosTransactionFeeInfo fee;

  @override
  State<CosmosSetTransferFeeView> createState() =>
      _CosmosSetTransferFeeViewState();
}

class _CosmosSetTransferFeeViewState extends State<CosmosSetTransferFeeView>
    with SafeState<CosmosSetTransferFeeView> {
  BigInt gasLimit = BigInt.zero;
  Token get feeToken => widget.fee.token;
  BigInt get max => widget.fee.maxFee;
  late IntegerBalance fee;
  bool isReady = true;

  void checkIsReady() {
    final isReady = fee.largerThanZero && !gasLimit.isNegative;
    if (isReady != this.isReady) {
      this.isReady = isReady;
    }
    updateState();
  }

  void onChangeMaxLimit(BigInt gasLimit) {
    this.gasLimit = gasLimit;
    checkIsReady();
  }

  void setFee(BigInt? fee) {
    if (fee == null) return;
    this.fee.updateBalance(fee);
    checkIsReady();
  }

  void setupFee() {
    if (!isReady) return;
    context.pop(CosmosFeeInfo(
        gasLimit: gasLimit,
        fee: Coin(denom: widget.fee.feeDenom, amount: fee.balance)));
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    gasLimit = widget.fee.gasLimit ?? BigInt.zero;
    fee = IntegerBalance(BigInt.zero, widget.fee.token.decimal!);
    fee.updateBalance(widget.fee.feeAmount.balance);
    checkIsReady();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "transaction_fee".tr,
            body: Text("transaction_fee_desc3".tr)),
        Text("gas_limit".tr, style: context.textTheme.titleMedium),
        Text("cosmis_fee_limit_desc".tr),
        WidgetConstant.height8,
        BigNumberTextField(
          defaultValue: gasLimit,
          label: "gas_limit".tr,
          min: BigInt.zero,
          max: CosmosConst.maxGasLimit,
          onChange: onChangeMaxLimit,
        ),
        WidgetConstant.height20,
        Text("transaction_fee".tr, style: context.textTheme.titleMedium),
        Text("cost_for_transaction".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: fee.largerThanZero,
          onRemoveIcon: Icon(Icons.edit, color: context.onPrimaryContainer),
          onRemove: () {
            context
                .openSliverBottomSheet<BigInt>(
                  "setup_custom_fee".tr,
                  child: SetupNetworkAmount(
                    token: feeToken,
                    max: max,
                    min: BigInt.zero,
                    subtitle: PageTitleSubtitle(
                        title: "transaction_fee".tr,
                        body: Column(
                          children: [
                            Text("transaction_fee_desc3".tr),
                            WidgetConstant.height8,
                            ContainerWithBorder(
                                child: CoinPriceView(
                              balance: fee,
                              token: feeToken,
                              style: context.textTheme.titleLarge,
                            )),
                          ],
                        )),
                  ),
                )
                .then(setFee);
          },
          child: CoinPriceView(
              balance: fee,
              token: feeToken,
              style: context.onPrimaryTextTheme.titleMedium,
              symbolColor: context.onPrimaryContainer),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                activePress: isReady,
                padding: WidgetConstant.paddingVertical40,
                onPressed: setupFee,
                child: Text("setup_custom_fee".tr)),
          ],
        )
      ],
    );
  }
}
