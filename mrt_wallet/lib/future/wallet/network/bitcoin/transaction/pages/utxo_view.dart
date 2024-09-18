import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/controller/impl/transaction.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

class BitcoinTransactionUtxoView extends StatelessWidget {
  const BitcoinTransactionUtxoView({required this.controller, super.key});
  final BitcoinTransactionImpl controller;
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
            bool hasUtxos = utxo.hasUtxo;
            if (hasUtxos && utxo.utxosWithBalance!.isEmpty) {
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
                          utxo.utxoAddressDetails.address.type.value,
                          style: context.theme.textTheme.labelLarge,
                        ),
                        OneLineTextWidget(
                          utxo.address,
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
                              balance: utxo.sumOfUtxos,
                              token: controller.network.coinParam.token,
                              style: context.textTheme.titleLarge),
                          Divider(color: context.colors.onPrimaryContainer),
                          ...List.generate(utxo.utxosWithBalance!.length,
                              (pos) {
                            final accoutUtxo = utxo.utxosWithBalance![pos];
                            final bool canSpend =
                                accoutUtxo.balance.balance > BigInt.zero;
                            final CashToken? token = accoutUtxo.utxo.token;
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
                                            balance: accoutUtxo.balance,
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
                                          child: SelectableView(
                                              text: accoutUtxo.utxo.vout
                                                  .toString()),
                                        )
                                      ],
                                    ),
                                    OneLineTextWidget(
                                      accoutUtxo.utxo.txHash,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                              color:
                                                  context.colors.onSecondary),
                                    ),
                                    if (token != null) ...[
                                      Divider(
                                          color: context.colors.onSecondary),
                                      _UtxoTokenInfo(token: token)
                                    ],
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

class _UtxoTokenInfo extends StatelessWidget {
  const _UtxoTokenInfo({required this.token});
  final CashToken token;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("category_id".tr,
            style: context.textTheme.labelLarge
                ?.copyWith(color: context.colors.onSecondary)),
        OneLineTextWidget(
          token.category,
          style: context.textTheme.bodyMedium
              ?.copyWith(color: context.colors.onSecondary),
        ),
        if (token.hasAmount) ...[
          WidgetConstant.height8,
          Text("amount".tr,
              style: context.textTheme.labelLarge
                  ?.copyWith(color: context.colors.onSecondary)),
          Text(token.amount.toString().to3Digits,
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.onSecondary))
        ],
        if (token.hasNFT) ...[
          WidgetConstant.height8,
          Text("capability".tr,
              style: context.textTheme.labelLarge
                  ?.copyWith(color: context.colors.onSecondary)),
          Text(token.capability!.name.tr,
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: context.colors.onSecondary))
        ]
      ],
    );
  }
}
