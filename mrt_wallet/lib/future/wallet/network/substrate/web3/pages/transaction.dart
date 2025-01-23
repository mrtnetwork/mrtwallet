import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/transaction/pages/pages/fee_info.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/web3/controller/controller/transaction.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';

class SubstrateWeb3TransactionFieldsView extends StatelessWidget {
  const SubstrateWeb3TransactionFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3SubstrateRequest<Map<String, dynamic>, Web3SubstrateSendTransaction>
      request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3PageRequestControllerView(
        controller: () => Web3SubstrateTransactionRequestController(
            walletProvider: wallet, request: request),
        builder: (context, controller) {
          return [
            SliverToBoxAdapter(
                child: SubstrateShowPayloadInfoWidget(
                    payload: controller.extrinsicInfo)),
            SliverToBoxAdapter(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SubstrateTransactionFeeView(controller),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  FixedElevatedButton(
                      padding: WidgetConstant.paddingVertical40,
                      onPressed: () {
                        controller.signAndSendTransaction();
                      },
                      child: Text("sign_transaction".tr))
                ])
              ],
            )),
          ];
        },
        request: request);
  }
}
