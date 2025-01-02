import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/controller/impl/transaction.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/bch/transaction/cotnroller/transaction_controller.dart';
import 'package:mrt_wallet/future/wallet/network/bch/transaction/transaction/build_transaction.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/transaction/pages/send_transaction.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/transaction/pages/utxo_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

class SendBitcoinCashTransactionView extends StatelessWidget {
  const SendBitcoinCashTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main);
    final BitcoinChain appChain = context.getArgruments();
    return MrtViewBuilder<BitcoinCashStateController>(
      controller: () => BitcoinCashStateController(
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
              child: (c) => CustomScrollView(
                slivers: [
                  SliverConstraintsBoxView(
                    padding: WidgetConstant.paddingHorizontal20,
                    sliver: APPSliverAnimatedSwitcher(
                        enable: controller.page,
                        widgets: {
                          BitcoinTransactionPages.send: (context) =>
                              BitcoinCashBuildTransactionView(
                                  controller: controller),
                          BitcoinTransactionPages.account: (context) =>
                              SelectAccountUtxo(
                                controller: controller,
                                includeTokenUtxos: controller.includeTokenUtxos,
                                toggleTokenUtxos: () {
                                  controller.toggleTokenUtxos();
                                },
                              ),
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
