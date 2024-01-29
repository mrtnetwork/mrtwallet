import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_pages/controller/impl/transaction.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_pages/transaction/utxo_view.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/wallet_pages.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/bitcoin/bitcoin_account.dart';
import 'package:mrt_wallet/models/wallet_models/chain/chain.dart';
import 'package:mrt_wallet/types/typedef.dart';

class SendBitcoinTransactionView extends StatelessWidget {
  const SendBitcoinTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    final AppChain appChain = context.getArgruments();
    return MrtViewBuilder<BitcoinStateController>(
      controller: () => BitcoinStateController(
          walletProvider: wallet, chainAccount: appChain),
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
                              : controller.inUtxoPage
                                  ? Column(
                                      children: [
                                        BitcoinTransactionUtxoView(
                                            controller: controller),
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
                                  : SelectAccountUtxo(controller: controller),
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

class SelectAccountUtxo extends StatefulWidget {
  const SelectAccountUtxo({
    super.key,
    required this.controller,
    this.toggleTokenUtxos,
    this.includeTokenUtxos,
  });
  final BitcoinTransactionImpl controller;
  final DynamicVoid? toggleTokenUtxos;
  final bool? includeTokenUtxos;

  @override
  State<SelectAccountUtxo> createState() => _SelectAccountUtxoState();
}

class _SelectAccountUtxoState extends State<SelectAccountUtxo> {
  late final List<IBitcoinAddress> addresses =
      List.from(widget.controller.addresses)
        ..sort(
          (a, b) => a == widget.controller.account.address ? 0 : 1,
        );
  late final IBitcoinAddress currentAccount = addresses.first;

  bool showAll = true;

  void toggleShowAll() {
    showAll = !showAll;
    setState(() {});
    if (!showAll) {
      bool alert = false;
      for (final i in addresses) {
        if (i == currentAccount) continue;
        if (widget.controller
            .addressSelected(i.networkAddress.addressProgram)) {
          widget.controller.addAccount(i);
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
      key: const ValueKey<BitcoinTransactionPages>(
          BitcoinTransactionPages.account),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StreamWidget(
                        buttomWidget: FilledButton.icon(
                            onPressed: widget.controller.updateBalances,
                            icon: const Icon(Icons.update),
                            label: Text("update_balances".tr)),
                        backToIdle: AppGlobalConst.animationDuraion,
                        key: widget.controller.updateBalancessKey)
                  ],
                )
              ],
            )),
        if (widget.controller.isBCHTransaction)
          if (widget.includeTokenUtxos != null)
            AppSwitchListTile(
              value: widget.includeTokenUtxos!,
              onChanged: (p0) => widget.toggleTokenUtxos!(),
              title: Text("token_utxos".tr),
              subtitle: Text("includ_token_utxos".tr),
            ),
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
                fillColor: MaterialStatePropertyAll(context.colors.onSecondary),
                checkColor: context.colors.secondary,
                activeColor: context.colors.secondary,
                value: widget.controller.addressSelected(
                    currentAccount.networkAddress.addressProgram),
                onChanged:
                    currentAccount.address.balance.value.balance > BigInt.zero
                        ? (v) {
                            widget.controller.addAccount(currentAccount);
                          }
                        : null),
            onRemove: currentAccount.address.balance.value.balance > BigInt.zero
                ? () {
                    widget.controller.addAccount(currentAccount);
                  }
                : null,
            child: AddressDetailsView(
              address: currentAccount,
              color: context.colors.onSecondary,
            )),
        AnimatedSize(
          duration: AppGlobalConst.animationDuraion,
          child: showAll
              ? Column(
                  children: List.generate(addresses.length, (index) {
                    final bool isSelected = currentAccount == addresses[index];
                    if (isSelected) return WidgetConstant.sizedBox;
                    final balance =
                        addresses[index].address.balance.value.balance;
                    final bool canSpend = balance > BigInt.zero;

                    return ContainerWithBorder(
                        validate: canSpend,
                        validateText: "lacks_an_utxos".tr,
                        onRemoveIcon: Checkbox(
                          value: widget.controller.addressSelected(
                              addresses[index].networkAddress.addressProgram),
                          onChanged: (value) {
                            widget.controller.addAccount(addresses[index]);
                          },
                        ),
                        onRemove: () {
                          widget.controller.addAccount(addresses[index]);
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
