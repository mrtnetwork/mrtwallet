import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/controller/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/controller/impl/transaction.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/transaction/pages/ordering/transaction_ordering_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class BitcoinBuildTransactionView extends StatelessWidget {
  const BitcoinBuildTransactionView({super.key, required this.controller});
  final BitcoinStateController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("spendable_amount".tr, style: context.textTheme.titleMedium),
        WidgetConstant.height8,
        ContainerWithBorder(
          child: AnimatedSwitcher(
            duration: APPConst.animationDuraion,
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
              iconAlginment: CrossAxisAlignment.start,
              onRemoveIcon: const Icon(Icons.remove_circle),
              validate: controller.receivers[index].hasAmount,
              onRemove: () {
                controller.removeReceiver(controller.receivers[index].address);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerWithBorder(
                      backgroundColor: context.colors.secondary,
                      child: ReceiptAddressDetailsView(
                        address: controller.receivers[index].address,
                        color: context.colors.onSecondary,
                      )),
                  ContainerWithBorder(
                    onRemove: () {
                      context
                          .openSliverBottomSheet<BigInt>(
                        "setup_output_amount".tr,
                        child: SetupNetworkAmount(
                          token: controller.network.coinParam.token,
                          max: controller.remindAmount.balance +
                              controller.receivers[index].balance.balance,
                          min: controller.minimumOutput,
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
                        controller.setupAccountAmount(
                            controller.receivers[index].address.networkAddress
                                .addressProgram,
                            amount);
                      });
                    },
                    validate: controller.receivers[index].hasAmount,
                    onRemoveIcon:
                        Icon(Icons.edit, color: context.colors.onSecondary),
                    backgroundColor: context.colors.secondary,
                    child: CoinPriceView(
                      balance: controller.receivers[index].balance,
                      token: controller.network.coinParam.token,
                      style: context.textTheme.titleLarge
                          ?.copyWith(color: context.colors.onSecondary),
                      symbolColor: context.colors.onSecondary,
                    ),
                  )
                ],
              ),
            );
          }),
        ),
        ContainerWithBorder(
            validate: controller.receivers.isNotEmpty,
            onRemove: () {
              context
                  .openSliverBottomSheet<ReceiptAddress<BitcoinBaseAddress>>(
                      "receiver_address".tr,
                      bodyBuilder: (c) =>
                          SelectRecipientAccountView<BitcoinBaseAddress>(
                              account: controller.chainAccount,
                              scrollController: c),
                      maxExtend: 1,
                      minExtent: 0.8,
                      initialExtend: 0.9)
                  .then(
                (value) {
                  controller.onAddRecever(value, () {
                    context.showAlert("address_already_exist".tr);
                  });
                },
              );
            },
            onRemoveIcon: const Icon(Icons.add_box),
            child: Text("tap_to_add_new_receipment".tr)),
        WidgetConstant.height20,
        Text("remaining_amount".tr, style: context.textTheme.titleMedium),
        Text("remaining_amount_and_receiver".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerWithBorder(
                backgroundColor: context.colors.secondary,
                child: CoinPriceView(
                  balance: controller.remindAmount,
                  token: controller.network.coinParam.token,
                  symbolColor: context.colors.onSecondary,
                  style: context.textTheme.titleLarge
                      ?.copyWith(color: context.colors.onSecondary),
                )),
            ContainerWithBorder(
              validate: !controller.remindAmount.isNegative,
              onRemoveIcon: Icon(Icons.edit, color: context.colors.onSecondary),
              backgroundColor: context.colors.secondary,
              validateText: "transaction_Insufficient_balance".tr,
              onRemove: () {
                context
                    .openSliverBottomSheet<ChainAccount>(
                      "select_account".tr,
                      child: SwitchOrSelectAccountView(
                        account: controller.chainAccount,
                        showMultiSig: true,
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
                  Text(controller.onChangeAddress.type.value,
                      style: context.textTheme.labelLarge
                          ?.copyWith(color: context.colors.onSecondary)),
                  OneLineTextWidget(
                    controller.onChangeAddressView,
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: context.colors.onSecondary),
                  )
                ],
              ),
            ),
          ],
        )),
        WidgetConstant.height20,
        Text("transaction_fee".tr, style: context.textTheme.titleMedium),
        Text("cost_for_transaction".tr),
        WidgetConstant.height8,
        ContainerWithBorder(
          validateText: controller.feeError?.tr,
          validate: controller.feeError == null,
          onRemove: () {
            context
                .openSliverBottomSheet<(String?, BigInt?)>(
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
        Text("bitcoin_rbf_error".tr),
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
        Text("memo_desc2"
            .tr
            .replaceOne(controller.network.coinParam.token.name)),
        WidgetConstant.height8,
        ...List.generate(controller.memoScripts.length, (index) {
          return ContainerWithBorder(
              onRemove: () {
                controller.onRemoveMemo(controller.memoScripts[index]);
              },
              child: Text(controller.memoScripts[index].memo));
        }),
        ContainerWithBorder(
            onRemoveIcon: const Icon(Icons.add_box),
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
                    buttonText: "setup_memo".tr,
                    label: "memo".tr,
                  ),
                );
                return result;
              });
            },
            child: Text("tap_to_add_memo".tr,
                style: context.textTheme.labelLarge)),
        WidgetConstant.height20,
        Text("transaction_ordering".tr, style: context.textTheme.titleMedium),
        Text("transaction_ordering_desc".tr),
        ContainerWithBorder(
            child: AppDropDownBottom(
          key: UniqueKey(),
          items: {
            for (final i in TransactionOrdering.values) i: Text(i.name.tr)
          },
          itemBuilder: {
            for (final i in TransactionOrdering.values)
              i: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(i.name.tr),
                  Text(i.desc.tr, style: context.textTheme.bodySmall)
                ],
              )
          },
          label: "transaction_ordering".tr,
          value: controller.ordering,
          onChanged: (p0) {
            controller.onChangeOrdering(p0, (p0, p1) async {
              return context.openSliverBottomSheet("transaction_ordering".tr,
                  bodyBuilder: (c) => TransactionOrderingView(
                        inputs: p0,
                        outputs: p1,
                        network: controller.network,
                      ),
                  minExtent: 0.9,
                  maxExtend: 1,
                  initialExtend: 0.9);
            });
          },
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
