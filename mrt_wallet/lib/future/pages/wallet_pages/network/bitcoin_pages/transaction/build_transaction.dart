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
              children: [Text("build_transaction_desc1".tr)],
            )),
        Text("spendable_amount".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          child: AnimatedSwitcher(
            duration: AppGlobalConst.animationDuraion,
            child: Row(
              key: ValueKey(controller.spendableAmount.price),
              children: [
                Expanded(
                  child: CoinPriceView(
                      balance: controller.spendableAmount,
                      token: controller.network.coinParam.token,
                      style: context.textTheme.titleLarge),
                ),
              ],
            ),
          ),
        ),
        WidgetConstant.height20,
        Text("list_of_recipients".tr, style: context.textTheme.titleMedium),
        Text("amount_for_each_output".tr),
        WidgetConstant.height8,
        Column(
          children: List.generate(controller.receivers.length, (index) {
            return ContainerWithBorder(
              onRemoveIcon: const Icon(Icons.add_box),
              validate: controller.receivers[index].hasAmount,
              onRemove: () {
                context
                    .openSliverBottomSheet<BigInt>(
                  "setup_output_amount".tr,
                  child: SetupNetworkAmount(
                    token: controller.network.coinParam.token,
                    max: controller.remindAmount.balance,
                    min: BigInt.zero,
                    subtitle: PageTitleSubtitle(
                        title: "receiver".tr,
                        body: ContainerWithBorder(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                controller.receivers[index].address
                                    .networkAddress.type.value,
                                style: context.textTheme.labelLarge),
                            OneLineTextWidget(
                                controller.receivers[index].viewAddress)
                          ],
                        ))),
                  ),
                )
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
                      controller
                          .receivers[index].address.networkAddress.type.value,
                      style: context.textTheme.labelLarge),
                  OneLineTextWidget(controller.receivers[index].viewAddress),
                  CoinPriceView(
                    balance: controller.receivers[index].balance,
                    token: controller.network.coinParam.token,
                    style: context.textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }),
        ),
        WidgetConstant.height20,
        Text("remaining_amount".tr, style: context.textTheme.titleMedium),
        Text("remaining_amount_and_receiver".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("amount".tr, style: context.textTheme.labelLarge),
            CoinPriceView(
              balance: controller.remindAmount,
              token: controller.network.coinParam.token,
              style: context.textTheme.titleLarge,
            ),
          ],
        )),
        ContainerWithBorder(
          validate: !controller.remindAmount.isNegative,
          onRemoveIcon: const Icon(Icons.edit),
          validateText: "transaction_Insufficient_balance".tr,
          onRemove: () {
            context
                .openSliverBottomSheet<CryptoAccountAddress>(
                  "select_account".tr,
                  bodyBuilder: (c) => SwitchOrSelectAccountView(
                    account: controller.account,
                  ),
                  minExtent: 0.5,
                  maxExtend: 0.9,
                  initialExtend: 0.7,
                  centerContent: false,
                )
                .then(controller.changeAccount);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("receiver".tr, style: context.textTheme.labelLarge),
              Text(controller.onChangeAddress.type.value,
                  style: context.textTheme.labelLarge),
              OneLineTextWidget(controller.onChangeAddressView)
            ],
          ),
        ),
        WidgetConstant.height20,
        Text("transaction_fee".tr, style: context.textTheme.titleMedium),
        Text("cost_for_transaction".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          onRemove: () {
            context
                .openSliverBottomSheet<(BitcoinFeeRateType?, BigInt?)>(
              "transaction_fee".tr,
              child: SetupTransactionFee(
                fees: controller.fees,
                network: controller.network,
                type: controller.feeRateType?.name,
                max: controller.sumOfSelectedUtxo.balance,
                customFee: controller.transactionFee.balance,
              ),
            )
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
                token: controller.network.coinParam.token,
                style: context.textTheme.titleLarge,
              )
            ],
          ),
        ),
        WidgetConstant.height20,
        Text("replace_by_fee".tr, style: context.textTheme.titleMedium),
        Text("rbf_desc".tr),
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
                child: Text("replace_by_fee".tr,
                    style: context.textTheme.labelLarge),
              ),
              Switch(value: controller.rbf, onChanged: controller.toggleRbf),
            ],
          )),
        ),
        WidgetConstant.height20,
        Text("setup_memo".tr, style: context.textTheme.titleMedium),
        Text("memo_desc2".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            onRemoveIcon: controller.hasMemo
                ? const Icon(Icons.remove_circle)
                : const Icon(Icons.add_box),
            onRemove: () {
              controller.onTapMemo(() async {
                final result = await context.openSliverBottomSheet<String>(
                  "transaction_memo".tr,
                  child: StringWriterView(
                    title: PageTitleSubtitle(
                        title: "setup_memo".tr,
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("memo_desc1".tr),
                            WidgetConstant.height8,
                            Text("empty_desc".tr),
                          ],
                        )),
                    buttomText: "setup_memo".tr,
                    label: "memo".tr,
                  ),
                );
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
                      controller.sendTransaction();
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
