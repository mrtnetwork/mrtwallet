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
    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(
        child: Column(
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
                          style: context.onPrimaryTextTheme.titleMedium,
                          symbolColor: context.onPrimaryContainer),
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
          ],
        ),
      ),
      SliverList.separated(
        separatorBuilder: (context, index) => WidgetConstant.divider,
        itemBuilder: (context, index) {
          final utxo = controller.utxos[index];
          final bool hasUtxos = utxo.hasUtxo;
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
                      Text(utxo.owner.addressType.name,
                          style: context.onPrimaryTextTheme.labelLarge),
                      OneLineTextWidget(utxo.owner.address,
                          style: context.onPrimaryTextTheme.bodyMedium),
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
                            style: context.onPrimaryTextTheme.titleMedium,
                            symbolColor: context.onPrimaryContainer),
                        Divider(color: context.onPrimaryContainer),
                        ...List.generate(utxo.utxos!.length, (pos) {
                          final accoutUtxo = utxo.utxos![pos];
                          final bool canSpend = accoutUtxo.utxo.canSpend;
                          return ContainerWithBorder(
                            onRemove: () {
                              if (!canSpend) return;
                              controller.addUtxo(accoutUtxo);
                            },
                            enableTap: canSpend,
                            onRemoveWidget: APPCheckBox(
                              value: controller.utxoSelected(accoutUtxo),
                              activePress: canSpend,
                              ignoring: true,
                              onChanged: (p0) {},
                            ),
                            backgroundColor: context.onPrimaryContainer,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OneLineTextWidget(accoutUtxo.utxo.txHash,
                                    style: context.primaryTextTheme.bodyMedium),
                                Divider(color: context.primaryContainer),
                                CoinPriceView(
                                  balance: accoutUtxo.utxoBalance,
                                  token: controller.network.coinParam.token,
                                  symbolColor: context.primaryContainer,
                                  style: context.primaryTextTheme.titleMedium,
                                ),
                                Text(
                                    "n_asset".tr.replaceOne(
                                        accoutUtxo.utxo.totalAssets.toString()),
                                    style: context.primaryTextTheme.labelSmall),
                              ],
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
        },
        itemCount: controller.utxos.length,
      ),
      WidgetConstant.sliverPaddingVertial20,
    ]);
  }
}
