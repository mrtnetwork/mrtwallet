import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_cash_pages/transaction/cotnroller/transaction_controller.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_cash_pages/transaction/transaction/build_transaction.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_pages/transaction/send_transaction.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_pages/transaction/utxo_view.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/chain/chain.dart';

class SendBitcoinCashTransactionView extends StatelessWidget {
  const SendBitcoinCashTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateIdsConst.main);
    final AppChain appChain = context.getArgruments();
    return MrtViewBuilder<BitcoinCashStateController>(
      controller: () => BitcoinCashStateController(
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
