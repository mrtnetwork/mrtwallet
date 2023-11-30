import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class BitcoinBuildTransactionView extends StatelessWidget {
  const BitcoinBuildTransactionView({super.key, required this.controller});
  final BitcoinStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "build_transaction".tr,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("input_for_each_entery".tr),
                WidgetConstant.height8,
                Text("build_transaction_desc1".tr)
              ],
            )),
        Text("list_of_recipients".tr, style: context.textTheme.titleLarge),
        WidgetConstant.height8,
        Column(
          children: List.generate(controller.receivers.length, (index) {
            return ContainerWithBorder(
              onRemoveIcon: const Icon(Icons.add_box),
              validate: controller.receivers[index].hasAmount,
              onRemove: () {
                context
                    .openSliverBottomSheet<BigInt>(
                        SetupNetworkAmount(
                          network: controller.network,
                          max: controller.remindAmount.balance,
                          min: BigInt.zero,
                          subtitle: PageTitleSubtitle(
                              title: "receiver".tr,
                              body: ContainerWithBorder(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      controller
                                          .receivers[index].address.type.value,
                                      style: context.textTheme.labelLarge),
                                  OneLineTextWidget(
                                      controller.receivers[index].viewAddress)
                                ],
                              ))),
                        ),
                        "setup_output_amount".tr)
                    .then((amount) {
                  if (context.mounted) {
                    controller.setupAccountAmount(
                        controller.receivers[index].viewAddress, amount);
                  }
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.receivers[index].address.type.value,
                    style: context.textTheme.labelLarge,
                  ),
                  OneLineTextWidget(controller.receivers[index].viewAddress),
                  CoinPriceView(
                    balance: controller.receivers[index].balance,
                    coinNames: controller.network.coinParam,
                    style: context.textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }),
        ),
        WidgetConstant.height20,
        Text("the_remaining_amount".tr, style: context.textTheme.titleLarge),
        WidgetConstant.height8,
        ContainerWithBorder(
          validate: !controller.remindAmount.isNegative,
          onRemoveIcon: const Icon(Icons.edit),
          validateText: "transaction_Insufficient_balance".tr,
          onRemove: () {
            context
                .openSliverBottomSheet<CryptoAddress>(
                    const SwitchOrSelectAccountView(), "select_account".tr,
                    minExtent: 0.5, maxExtend: 0.9, initialExtend: 0.7)
                .then(controller.changeAccount);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("amount".tr, style: context.textTheme.labelLarge),
              CoinPriceView(
                balance: controller.remindAmount,
                coinNames: controller.network.coinParam,
                style: context.textTheme.titleLarge,
              ),
              WidgetConstant.height8,
              Text("receiver".tr, style: context.textTheme.labelLarge),
              Text(controller.onChangeAddress.type.value,
                  style: context.textTheme.labelLarge),
              OneLineTextWidget(controller.onChangeAddressView)
            ],
          ),
        ),
        WidgetConstant.height20,
        Text(
          "transaction_fee".tr,
          style: context.textTheme.titleLarge,
        ),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {
            context
                .openSliverBottomSheet<(BitcoinFeeRateType?, BigInt?)>(
                    _SelectBitcoinFee(
                      feeRate: controller.feeRate,
                      network: controller.network,
                      transactionSize: controller.trSize,
                      type: controller.feeRateType,
                      max: controller.sumOfSelectedUtxo.balance,
                      customFee: controller.transactionFee.balance,
                    ),
                    "transaction_fee".tr)
                .then((value) {
              controller.setFee(value?.$1, customFee: value?.$2);
            });
          },
          onRemoveIcon: const Icon(Icons.edit),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.feeRateType?.name.camelCase ?? "custom_fee".tr,
                  style: context.textTheme.labelLarge),
              CoinPriceView(
                balance: controller.transactionFee,
                coinNames: controller.network.coinParam,
                style: context.textTheme.titleLarge,
              )
            ],
          ),
        ),
        WidgetConstant.height20,
        Text(
          "replace_by_fee".tr,
          style: context.textTheme.titleLarge,
        ),
        WidgetConstant.height8,
        InkWell(
          borderRadius: WidgetConstant.border8,
          onTap: () {
            controller.toggleRbf(false);
          },
          child: ContainerWithBorder(
              child: Row(
            children: [
              Expanded(
                child: Text(
                  "replace_by_fee".tr,
                  style: context.textTheme.labelLarge,
                ),
              ),
              Switch(value: controller.rbf, onChanged: controller.toggleRbf),
            ],
          )),
        ),
        WidgetConstant.height20,
        Text(
          "setup_memo".tr,
          style: context.textTheme.titleLarge,
        ),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemoveIcon: controller.hasMemo
                ? const Icon(Icons.remove_circle)
                : const Icon(Icons.add_box),
            onRemove: () {
              controller.onTapMemo(() async {
                final result = await context.openSliverBottomSheet<String>(
                    StringWriterView(
                      title: PageTitleSubtitle(
                          title: "setup_memo".tr,
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("memo_desc1".tr),
                              WidgetConstant.height8,
                              Text("memo_desc2".tr),
                            ],
                          )),
                      buttomText: "setup_memo".tr,
                      label: "memo".tr,
                    ),
                    "transaction_memo".tr);
                return result;
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: controller.hasMemo
                      ? Text(controller.memo ?? "")
                      : Text("tap_to_add_memo".tr,
                          style: context.textTheme.labelLarge),
                ),
              ],
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical20,
              onPressed: controller.trReady
                  ? () {
                      controller.sigTr();
                    }
                  : null,
              child: Text("send_transaction".tr),
            ),
          ],
        )
      ],
    );
  }
}

class _SelectBitcoinFee extends StatefulWidget {
  const _SelectBitcoinFee(
      {required this.feeRate,
      required this.type,
      required this.transactionSize,
      required this.network,
      this.customFee,
      this.max});
  final BitcoinFeeRate feeRate;
  final AppBitcoinNetwork network;
  final BitcoinFeeRateType? type;
  final int transactionSize;
  final BigInt? max;
  final BigInt? customFee;
  @override
  State<_SelectBitcoinFee> createState() => _SelectBitcoinFeeState();
}

class _SelectBitcoinFeeState extends State<_SelectBitcoinFee> with SafeState {
  late BitcoinFeeRateType? type = widget.type;
  late final CurrencyBalance feeRate = CurrencyBalance(
      widget.feeRate.getEstimate(widget.transactionSize,
          customFeeRatePerKb: widget.customFee,
          feeRateType: type ?? BitcoinFeeRateType.medium),
      widget.network.coinParam.decimal);
  late final Map<BitcoinFeeRateType?, CurrencyBalance> fees = {
    BitcoinFeeRateType.medium: CurrencyBalance(
        widget.feeRate.getEstimate(widget.transactionSize,
            feeRateType: BitcoinFeeRateType.medium),
        widget.network.coinParam.decimal),
    BitcoinFeeRateType.low: CurrencyBalance(
        widget.feeRate.getEstimate(widget.transactionSize,
            feeRateType: BitcoinFeeRateType.low),
        widget.network.coinParam.decimal),
    BitcoinFeeRateType.high: CurrencyBalance(
        widget.feeRate.getEstimate(widget.transactionSize,
            feeRateType: BitcoinFeeRateType.high),
        widget.network.coinParam.decimal),
  };
  void onChange(BitcoinFeeRateType? newType, {BigInt? customPrice}) {
    if (newType == null && customPrice == null) return;
    if (newType != null && customPrice != null) return;
    type = newType;
    feeRate.updateBalance(customPrice ?? BigInt.zero);
    setState(() {});
  }

  void onSetup() {
    if (mounted) {
      context.pop((type, feeRate.balance));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "bitcoin_transaction_fee".tr,
            body: Column(
              children: [
                Text("transacation_fee_desc".tr),
                WidgetConstant.height8,
                Text("transaction_fee_desc2".tr),
                WidgetConstant.height8,
                Text("transaction_fee_desc3".tr)
              ],
            )),
        Column(children: [
          AppRadioListTile(
            value: BitcoinFeeRateType.high,
            title: Text(BitcoinFeeRateType.high.name.camelCase),
            subtitle: CoinPriceView(
              balance: fees[BitcoinFeeRateType.high]!,
              coinNames: widget.network.coinParam,
              disableTooltip: true,
              style: context.textTheme.titleLarge,
            ),
            groupValue: type,
            onChanged: (value) {
              onChange(BitcoinFeeRateType.high);
            },
          ),
          AppRadioListTile(
            value: BitcoinFeeRateType.medium,
            title: Text(BitcoinFeeRateType.medium.name.camelCase),
            subtitle: CoinPriceView(
              balance: fees[BitcoinFeeRateType.medium]!,
              disableTooltip: true,
              coinNames: widget.network.coinParam,
              style: context.textTheme.titleLarge,
            ),
            groupValue: type,
            onChanged: (value) {
              onChange(BitcoinFeeRateType.medium);
            },
          ),
          AppRadioListTile(
            value: BitcoinFeeRateType.low,
            title: Text(BitcoinFeeRateType.low.name.camelCase),
            subtitle: CoinPriceView(
              balance: fees[BitcoinFeeRateType.low]!,
              coinNames: widget.network.coinParam,
              disableTooltip: true,
              style: context.textTheme.titleLarge,
            ),
            groupValue: type,
            onChanged: (value) {
              onChange(BitcoinFeeRateType.low);
            },
          ),
          AppRadioListTile(
            value: null,
            groupValue: type,
            title: Text("custom_fee".tr),
            subtitle: type == null
                ? CoinPriceView(
                    disableTooltip: true,
                    balance: feeRate,
                    coinNames: widget.network.coinParam,
                    style: context.textTheme.titleLarge,
                  )
                : null,
            onChanged: (value) {
              context
                  .openSliverBottomSheet<BigInt>(
                      SetupNetworkAmount(
                        network: widget.network,
                        max: widget.max,
                        min: BigInt.zero,
                        buttonText: "setup_transaction_fee".tr,
                        subtitle: PageTitleSubtitle(
                            title: "transaction_fee".tr,
                            body: Text("transaction_fee_desc4".tr)),
                      ),
                      "setup_custom_fee".tr)
                  .then((value) {
                onChange(null, customPrice: value);
              });
            },
          ),
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
                padding: WidgetConstant.paddingVertical20,
                onPressed: onSetup,
                child: Text("setup_custom_fee".tr))
          ],
        )
      ],
    );
  }
}
