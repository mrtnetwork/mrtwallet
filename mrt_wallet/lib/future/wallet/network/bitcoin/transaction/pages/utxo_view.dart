import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/bch/token/pages/cash_token_info.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/controller/impl/transaction.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/models/networks/bch/bitcoin_cash.dart';

class BitcoinTransactionUtxoView extends StatelessWidget {
  const BitcoinTransactionUtxoView({required this.controller, super.key});
  final BitcoinTransactionImpl controller;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
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
                        symbolColor: context.onPrimaryContainer,
                        style: context.onPrimaryTextTheme.titleMedium),
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
            children: List.generate(controller.accountsUtxos.length, (index) {
              final utxo = controller.accountsUtxos[index];
              final bool hasUtxos = utxo.hasUtxo;
              if (hasUtxos && utxo.utxosWithBalance!.isEmpty) {
                return WidgetConstant.sizedBox;
              }
              return ContainerWithBorder(
                validate: hasUtxos,
                validateText: "utxo_receiving_err".tr,
                onTapError: () {
                  controller.fetchUtxos();
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            utxo.utxoAddressDetails.address.type.value,
                            style: context.onPrimaryTextTheme.labelLarge,
                          ),
                          OneLineTextWidget(utxo.address,
                              style: context.onPrimaryTextTheme.bodyMedium),
                          if (hasUtxos) ...[
                            CoinPriceView(
                                balance: utxo.sumOfUtxos,
                                token: controller.network.coinParam.token,
                                style: context.onPrimaryTextTheme.labelLarge,
                                symbolColor: context.onPrimaryContainer),
                            Divider(color: context.onPrimaryContainer),
                            ...List.generate(utxo.utxosWithBalance!.length,
                                (pos) {
                              final accoutUtxo = utxo.utxosWithBalance![pos];
                              final bool canSpend =
                                  accoutUtxo.balance.balance > BigInt.zero;
                              final BCHCashToken? token = accoutUtxo.cashToken;
                              return ContainerWithBorder(
                                backgroundColor: context.onPrimaryContainer,
                                onRemoveWidget: APPCheckBox(
                                    value: controller.utxoSelected(accoutUtxo),
                                    color: context.onPrimaryContainer,
                                    backgroundColor: context.primaryContainer,
                                    ignoring: true),
                                onRemove: canSpend
                                    ? () {
                                        controller.addUtxo(accoutUtxo);
                                      }
                                    : null,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    OneLineTextWidget(accoutUtxo.txHash,
                                        style: context
                                            .primaryTextTheme.bodyMedium),
                                    CoinPriceView(
                                        balance: accoutUtxo.balance,
                                        token:
                                            controller.network.coinParam.token,
                                        symbolColor: context.primaryContainer,
                                        showTokenImage: true,
                                        style: context
                                            .primaryTextTheme.titleMedium),
                                    if (token != null) ...[
                                      Divider(color: context.primaryContainer),
                                      BCHCashTokenDetailsView(
                                          token: token,
                                          color: context.primaryContainer)
                                    ],
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
            }),
          ),
        ],
      ),
    );
  }
}
