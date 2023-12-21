import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';

class SendBitcoinTransactionView extends StatelessWidget {
  const SendBitcoinTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);

    return MrtViewBuilder<BitcoinStateController>(
      controller: () => BitcoinStateController(wallet),
      builder: (controller) {
        return PopScope(
          canPop: controller.canPopPage,
          onPopInvoked: (didPop) {
            if (!didPop) {
              controller.onBackButtom();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text("build_transacation".tr),
            ),
            body: PageProgress(
              key: controller.progressKey,
              backToIdle: AppGlobalConst.oneSecoundDuration,
              child: () => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ConstraintsBoxView(
                      padding: WidgetConstant.padding20,
                      child: AnimatedSwitcher(
                        duration: AppGlobalConst.animationDuraion,
                        child: SizedBox(
                          key: ValueKey<int>(controller.receivers.length),
                          child: controller.inSendPage
                              ? BitcoinBuildTransactionView(
                                  controller: controller)
                              : controller.inReceiverPage
                                  ? BitcoinTransactionReceiverView(
                                      controller: controller)
                                  : controller.inUtxoPage
                                      ? _UtxoPage(controller: controller)
                                      : _SelectAccountUtxo(
                                          controller: controller),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SelectAccountUtxo extends StatelessWidget {
  const _SelectAccountUtxo({required this.controller});
  final BitcoinStateController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey<BitcoinTransactionPages>(
          BitcoinTransactionPages.account),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "create_and_send_network_transaction"
                .tr
                .replaceOne(controller.network.coinParam.token.name),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("spend_multiple_account_desc".tr),
                WidgetConstant.height20,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StreamWidget(
                        buttomWidget: FilledButton.icon(
                            onPressed: controller.updateBalances,
                            icon: const Icon(Icons.update),
                            label: Text("update_balances".tr)),
                        backToIdle: AppGlobalConst.animationDuraion,
                        key: controller.updateBalancessKey)
                  ],
                )
              ],
            )),
        Text("accounts".tr, style: context.textTheme.titleMedium),
        Text("please_selected_acc_spend"
            .tr
            .replaceOne(controller.network.coinParam.token.name)),
        WidgetConstant.height8,
        Column(
          children: List.generate(controller.addresses.length, (index) {
            final balance =
                controller.addresses[index].address.balance.value.balance;
            final String address =
                controller.addresses[index].address.toAddress;
            final bool canSpend = balance > BigInt.zero;
            return InkWell(
              borderRadius: WidgetConstant.border8,
              onTap: canSpend
                  ? () {
                      controller.addAccount(controller.addresses[index]);
                    }
                  : null,
              child: ContainerWithBorder(
                  validate: canSpend,
                  validateText: "lacks_an_utxos".tr,
                  onRemoveIcon: Checkbox(
                      value: controller.addressSelected(address),
                      onChanged: canSpend
                          ? (v) {
                              controller
                                  .addAccount(controller.addresses[index]);
                            }
                          : null),
                  onRemove: canSpend
                      ? () {
                          controller.addAccount(controller.addresses[index]);
                        }
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(controller.addresses[index].addressType.value,
                            style: context.textTheme.labelLarge),
                        WidgetConstant.width8,
                        Flexible(
                          child: OneLineTextWidget(
                              controller.addresses[index].address.updated
                                  .toDateAndTime(),
                              style: context.textTheme.bodySmall),
                        )
                      ]),
                      OneLineTextWidget(address,
                          style: context.textTheme.bodyMedium),
                      Text(controller.addresses[index].keyIndex.path.tr),
                      CoinPriceView(
                        account: controller.addresses[index],
                        style: context.textTheme.titleLarge,
                        disableTooltip: true,
                      )
                    ],
                  )),
            );
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical20,
              onPressed: controller.hasSpender ? controller.fetchUtxos : null,
              child: Text("get_unspent_transaction".tr),
            ),
          ],
        ),
      ],
    );
  }
}

class _UtxoPage extends StatelessWidget {
  const _UtxoPage({required this.controller});
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
        Text("utxos".tr, style: context.textTheme.titleMedium),
        Text("choose_utxos_each_account".tr),
        WidgetConstant.height8,
        if (controller.haveUtxos) ...[
          CheckboxListTile(
            title: Text("choose_all".tr),
            value: controller.allUtxosSelected,
            onChanged: (value) {
              controller.selectAll();
            },
          ),
          WidgetConstant.height8
        ],
        Column(
          children: List.generate(controller.utxos.length, (index) {
            return ContainerWithBorder(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.utxos[index].utxoAddressDetails.address
                              .type.value,
                          style: context.theme.textTheme.labelLarge,
                        ),
                        OneLineTextWidget(
                          controller.utxos[index].address,
                          style: context.textTheme.bodyMedium,
                        ),
                        if (!controller.utxos[index].hasUtxo)
                          Column(
                            children: [
                              Text(
                                "utxo_receiving_err".tr,
                                style: context.textTheme.bodySmall
                                    ?.copyWith(color: context.colors.error),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FilledButton(
                                      onPressed: controller.fetchUtxos,
                                      child: Text("attempt_again".tr))
                                ],
                              )
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CoinPriceView(
                                  balance: controller.utxos[index].sumOfUtxos,
                                  token: controller.network.coinParam.token,
                                  style: context.textTheme.titleLarge),
                              const Divider(),
                              // WidgetConstant.height8,
                              Column(
                                children: List.generate(
                                    controller.utxos[index].utxosWithBalance!
                                        .length, (pos) {
                                  final utxo = controller
                                      .utxos[index].utxosWithBalance![pos];
                                  final bool canSpend =
                                      utxo.balance.balance > BigInt.zero;
                                  return ContainerWithCheckBoxAndBorder(
                                    value: controller.utxoSelected(utxo),
                                    backgroundColor:
                                        context.colors.secondaryContainer,
                                    onChange: canSpend
                                        ? (p0) {
                                            controller.addUtxo(utxo);
                                          }
                                        : null,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CoinPriceView(
                                          balance: utxo.balance,
                                          token: controller
                                              .network.coinParam.token,
                                          style: context.textTheme.titleLarge,
                                        ),
                                        OneLineTextWidget(utxo.utxo.txHash),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical20,
              onPressed: controller.canBuildTransaction
                  ? controller.moveToReceiver
                  : null,
              child: Text("setup_recipients".tr),
            )
          ],
        )
      ],
    );
  }
}
