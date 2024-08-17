import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
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
            appBar: AppBar(
              title: Text("build_transacation".tr),
            ),
            body: PageProgress(
              key: controller.progressKey,
              backToIdle: APPConst.oneSecoundDuration,
              child: (c) => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ConstraintsBoxView(
                      padding: WidgetConstant.padding20,
                      child: AnimatedSwitcher(
                        duration: APPConst.animationDuraion,
                        child: SizedBox(
                          key: ValueKey<int>(controller.receivers.length),
                          child: controller.inSendPage
                              ? BitcoinCashBuildTransactionView(
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
                                  : SelectAccountUtxo(
                                      controller: controller,
                                      toggleTokenUtxos: () {
                                        controller.toggleTokenUtxos();
                                      },
                                      includeTokenUtxos:
                                          controller.includeTokenUtxos,
                                    ),
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
