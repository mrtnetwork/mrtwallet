import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/global/pages/address_details.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/controller/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/transaction/pages/build_transaction.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/controller/impl/transaction.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/transaction/pages/utxo_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class SendBitcoinTransactionView extends StatelessWidget {
  const SendBitcoinTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    final BitcoinChain appChain = context.getArgruments();
    return MrtViewBuilder<BitcoinStateController>(
      controller: () => BitcoinStateController(
          walletProvider: wallet, chainAccount: appChain),
      repositoryId: StateConst.bitcoin,
      builder: (controller) {
        return PopScope(
          canPop: controller.canPopPage,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) {
              controller.onBackButton();
            }
          },
          child: Scaffold(
            appBar: AppBar(title: Text("build_transacation".tr)),
            floatingActionButton:
                APPAnimatedSwitcher(enable: controller.page, widgets: {
              BitcoinTransactionPages.send: (context) => null,
              BitcoinTransactionPages.account: (context) => APPAnimatedSize(
                  isActive: controller.hasSpender,
                  onActive: (context) => FloatingActionButton.extended(
                      onPressed:
                          controller.hasSpender ? controller.fetchUtxos : null,
                      label: Text("get_unspent_transaction".tr)),
                  onDeactive: (context) => WidgetConstant.sizedBox),
              BitcoinTransactionPages.utxo: (context) => APPAnimatedSize(
                  isActive: controller.canBuildTransaction,
                  onActive: (context) => FloatingActionButton.extended(
                      onPressed: controller.canBuildTransaction
                          ? controller.onSetupUtxo
                          : null,
                      label: Text("setup_recipients".tr)),
                  onDeactive: (context) => WidgetConstant.sizedBox),
            }),
            body: PageProgress(
              key: controller.progressKey,
              backToIdle: APPConst.oneSecoundDuration,
              child: (context) => CustomScrollView(
                slivers: [
                  SliverConstraintsBoxView(
                    padding: WidgetConstant.paddingHorizontal20,
                    sliver: APPSliverAnimatedSwitcher(
                        enable: controller.page,
                        widgets: {
                          BitcoinTransactionPages.send: (context) =>
                              BitcoinBuildTransactionView(
                                  controller: controller),
                          BitcoinTransactionPages.account: (context) =>
                              SelectAccountUtxo(controller: controller),
                          BitcoinTransactionPages.utxo: (context) =>
                              BitcoinTransactionUtxoView(
                                  controller: controller),
                        }),
                  ),
                  WidgetConstant.sliverPaddingVertial40,
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
  const SelectAccountUtxo(
      {super.key,
      required this.controller,
      this.toggleTokenUtxos,
      this.includeTokenUtxos});
  final BitcoinTransactionImpl controller;
  final DynamicVoid? toggleTokenUtxos;
  final bool? includeTokenUtxos;

  @override
  State<SelectAccountUtxo> createState() => _SelectAccountUtxoState();
}

class _SelectAccountUtxoState extends State<SelectAccountUtxo> with SafeState {
  late final List<IBitcoinAddress> addresses =
      List.from(widget.controller.addresses)
        ..sort((a, b) => a == widget.controller.chainAccount.address ? 0 : 1);
  late final IBitcoinAddress currentAccount = addresses.first;

  bool showAll = true;

  void toggleShowAll() {
    showAll = !showAll;
    updateState();
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
    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitleSubtitle(
                title: "create_and_send_network_transaction"
                    .tr
                    .replaceOne(widget.controller.network.coinParam.token.name),
                body: Text("spend_multiple_account_desc".tr)),
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
                    fillColor:
                        WidgetStatePropertyAll(context.colors.onSecondary),
                    checkColor: context.colors.secondary,
                    activeColor: context.colors.secondary,
                    value: widget.controller.addressSelected(
                        currentAccount.networkAddress.addressProgram),
                    onChanged: currentAccount.address.hasBalance
                        ? (v) {
                            widget.controller.addAccount(currentAccount);
                          }
                        : null),
                onRemove: currentAccount.address.hasBalance
                    ? () {
                        widget.controller.addAccount(currentAccount);
                      }
                    : null,
                child: AddressDetailsView(
                  address: currentAccount,
                  color: context.colors.onSecondary,
                )),
          ],
        ),
      ),
      APPSliverAnimatedSwitcher(enable: showAll, widgets: {
        true: (context) => SliverList.separated(
              separatorBuilder: (context, index) => WidgetConstant.divider,
              itemBuilder: (context, index) {
                final bool isSelected = currentAccount == addresses[index];
                if (isSelected) return WidgetConstant.sizedBox;
                final balance = addresses[index].address.currencyBalance;
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
                    child: AddressDetailsView(
                        address: addresses[index],
                        color: context.colors.onPrimaryContainer));
              },
              itemCount: addresses.length,
            ),
      }),
    ]);
  }
}
