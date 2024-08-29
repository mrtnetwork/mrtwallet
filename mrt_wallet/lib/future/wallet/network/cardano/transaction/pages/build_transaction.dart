import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/account/pages/account_controller.dart';
import 'package:mrt_wallet/future/wallet/global/global.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/transaction/controller/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/transaction/controller/impl/transaction.dart';
import 'package:mrt_wallet/future/wallet/network/cardano/transaction/pages/utxo_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'send_transaction.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class SendCardanoTransactionView extends StatelessWidget {
  const SendCardanoTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<ADAChain>(
        childBulder: (wallet, account, onAccountChanged) {
          return MrtViewBuilder<CardanoTransactionStateController>(
            controller: () => CardanoTransactionStateController(
                walletProvider: wallet, chainAccount: account),
            repositoryId: StateConst.cardano,
            builder: (controller) {
              return PageProgress(
                key: controller.progressKey,
                initialStatus: StreamWidgetStatus.progress,
                backToIdle: APPConst.oneSecoundDuration,
                child: (c) => CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ConstraintsBoxView(
                        padding: WidgetConstant.padding20,
                        child: AnimatedSize(
                          duration: APPConst.animationDuraion,
                          child: controller.inSendPage
                              ? CardanoBuildTransactionView(
                                  controller: controller)
                              : controller.inUtxoPage
                                  ? Column(
                                      children: [
                                        CardanoTransactionUtxoView(
                                          controller: controller,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FixedElevatedButton(
                                              padding: WidgetConstant
                                                  .paddingVertical20,
                                              onPressed:
                                                  controller.canBuildTransaction
                                                      ? controller.onSetupUtxo
                                                      : null,
                                              child:
                                                  Text("setup_recipients".tr),
                                            )
                                          ],
                                        )
                                      ],
                                    )
                                  : _SelectAccountUtxo(controller: controller),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        title: "build_transacation".tr);
  }
}

class _SelectAccountUtxo extends StatefulWidget {
  const _SelectAccountUtxo({required this.controller});
  final CardanoTransactionImpl controller;

  @override
  State<_SelectAccountUtxo> createState() => _SelectAccountUtxoState();
}

class _SelectAccountUtxoState extends State<_SelectAccountUtxo> {
  late final List<ICardanoAddress> addresses =
      List.from(widget.controller.addresses)
        ..sort(
          (a, b) => a == widget.controller.chainAccount.address ? 0 : 1,
        );
  late final ICardanoAddress currentAccount = addresses.first;

  bool showAll = true;

  void toggleShowAll() {
    showAll = !showAll;
    setState(() {});
    if (!showAll) {
      bool alert = false;
      for (final i in addresses) {
        if (i == currentAccount || i.networkAddress.isRewardAddress) continue;
        if (widget.controller.addressSelected(i)) {
          widget.controller.addSpender(
            i,
            (p0) {
              context.showAlert(p0.tr);
            },
          );
          alert = true;
        }
      }
      if (alert) {
        context.showAlert("accounts_removed_from_spending_list".tr);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // key: const ValueKey<BitcoinTransactionPages>(
      //     BitcoinTransactionPages.account),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(
            title: "create_and_send_network_transaction"
                .tr
                .replaceOne(widget.controller.network.coinParam.token.name),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("spend_multiple_account_desc".tr),
                WidgetConstant.height20,
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     StreamWidget(
                //         buttonWidget: FilledButton.icon(
                //             onPressed: widget.controller.updateBalances,
                //             icon: const Icon(Icons.update),
                //             label: Text("update_balances".tr)),
                //         backToIdle: APPConst.animationDuraion,
                //         key: widget.controller.updateBalancessKey)
                //   ],
                // )
              ],
            )),
        Text("accounts".tr, style: context.textTheme.titleMedium),
        Text("please_selected_acc_spend"
            .tr
            .replaceOne(widget.controller.network.coinParam.token.name)),
        WidgetConstant.height8,
        AppSwitchListTile(
          value: showAll,
          title: Text("display_all_account".tr),
          subtitle: Text("spending_from_multiple_account".tr),
          onChanged: (p0) => toggleShowAll(),
        ),
        WidgetConstant.height8,
        ContainerWithBorder(
            backgroundColor: context.colors.secondary,
            validateText: "lacks_an_utxos".tr,
            onRemoveIcon: Checkbox(
                fillColor: WidgetStatePropertyAll(context.colors.onSecondary),
                checkColor: context.colors.secondary,
                activeColor: context.colors.secondary,
                value: widget.controller.addressSelected(currentAccount),
                onChanged: (v) {
                  widget.controller.addressSelected(currentAccount);
                }),
            onRemove: () {
              widget.controller.addSpender(
                currentAccount,
                (p0) {
                  context.showAlert(p0.tr);
                },
              );
            },
            child: AddressDetailsView(
              address: currentAccount,
              color: context.colors.onSecondary,
            )),
        AnimatedSize(
          duration: APPConst.animationDuraion,
          child: showAll
              ? Column(
                  children: List.generate(addresses.length, (index) {
                    final bool isSelected = currentAccount == addresses[index];
                    if (isSelected) return WidgetConstant.sizedBox;
                    final balance = addresses[index].address.currencyBalance;
                    final bool canSpend = balance > BigInt.zero;

                    return ContainerWithBorder(
                        validate: canSpend,
                        validateText: "lacks_an_utxos".tr,
                        onRemoveIcon: Checkbox(
                          value: widget.controller
                              .addressSelected(addresses[index]),
                          onChanged: (value) {
                            widget.controller.addSpender(
                              addresses[index],
                              (p0) {
                                context.showAlert(p0.tr);
                              },
                            );
                          },
                        ),
                        onRemove: () {
                          widget.controller.addSpender(
                            addresses[index],
                            (p0) {
                              context.showAlert(p0.tr);
                            },
                          );
                        },
                        child: AddressDetailsView(address: addresses[index]));
                  }),
                )
              : WidgetConstant.sizedBox,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FixedElevatedButton(
              padding: WidgetConstant.paddingVertical20,
              onPressed: widget.controller.hasSpender
                  ? widget.controller.fetchUtxos
                  : null,
              child: Text("get_unspent_transaction".tr),
            ),
          ],
        ),
      ],
    );
  }
}
