import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/transaction/controller/impl/transaction.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class CardanoTransactionUtxoView extends StatelessWidget {
  const CardanoTransactionUtxoView({required this.controller, super.key});
  final CardanoTransactionImpl controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("utxos_amount".tr, style: context.textTheme.titleMedium),
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
        Text("utxos".tr, style: context.textTheme.titleMedium),
        Text("choose_utxos_each_account".tr),
        WidgetConstant.height8,
        if (controller.haveUtxos) ...[
          AppCheckListTile(
            title: Text("choose_all".tr),
            subtitle: Text("choose_all_utxos".tr),
            value: controller.allUtxosSelected,
            onChanged: (value) {
              controller.selectAllUtxos();
            },
          ),
          WidgetConstant.height8
        ],
        Column(
          children: List.generate(controller.utxos.length, (index) {
            final utxo = controller.utxos[index];
            bool hasUtxos = utxo.hasUtxo;
            if (hasUtxos && utxo.utxoAmounts.isZero) {
              return WidgetConstant.sizedBox;
            }
            return ContainerWithBorder(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          utxo.owner.addressType.name,
                          style: context.theme.textTheme.labelLarge,
                        ),
                        OneLineTextWidget(
                          utxo.owner.address,
                          style: context.textTheme.bodyMedium,
                        ),
                        if (!hasUtxos) ...[
                          Text(
                            "utxo_receiving_err".tr,
                            style: context.textTheme.bodySmall
                                ?.copyWith(color: context.colors.error),
                          ),
                          WidgetConstant.height8,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FilledButton(
                                  onPressed: controller.fetchUtxos,
                                  child: Text("attempt_again".tr))
                            ],
                          )
                        ] else ...[
                          CoinPriceView(
                              balance: utxo.utxoAmounts,
                              token: controller.network.coinParam.token,
                              style: context.textTheme.titleLarge),
                          Divider(color: context.colors.onPrimaryContainer),
                          ...List.generate(utxo.utxos!.length, (pos) {
                            final accoutUtxo = utxo.utxos![pos];
                            final bool canSpend =
                                accoutUtxo.utxo.sumOflovelace > BigInt.zero;
                            return Theme(
                              data: context.theme.copyWith(
                                  checkboxTheme: context.theme.checkboxTheme
                                      .copyWith(
                                          fillColor: WidgetStatePropertyAll(
                                              context.colors.onSecondary),
                                          checkColor: WidgetStatePropertyAll(
                                              context.colors.secondary))),
                              child: ContainerWithCheckBoxAndBorder(
                                value: controller.utxoSelected(accoutUtxo),
                                backgroundColor: context.colors.secondary,
                                onChange: canSpend
                                    ? (p0) {
                                        controller.addUtxo(accoutUtxo);
                                      }
                                    : null,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CoinPriceView(
                                            balance: accoutUtxo.utxoBalance,
                                            token: controller
                                                .network.coinParam.token,
                                            symbolColor:
                                                context.colors.onSecondary,
                                            style: context.textTheme.titleLarge
                                                ?.copyWith(
                                                    color: context
                                                        .colors.onSecondary),
                                          ),
                                        ),
                                        WidgetConstant.height8,
                                        ToolTipView(
                                            waitDuration: null,
                                            message: "output_index_desc".tr,
                                            child: Badge.count(
                                                count: accoutUtxo
                                                    .utxo.outputIndex))
                                      ],
                                    ),
                                    Text(
                                      "n_asset".tr.replaceOne(accoutUtxo
                                          .utxo.totalAssets
                                          .toString()),
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                              color:
                                                  context.colors.onSecondary),
                                    ),
                                    WidgetConstant.height8,
                                    OneLineTextWidget(
                                      accoutUtxo.utxo.txHash,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                              color:
                                                  context.colors.onSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
