import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/state.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'global.dart';
import 'transaction.dart';

class CosmosWeb3FieldsView extends StatelessWidget {
  const CosmosWeb3FieldsView({super.key});
  @override
  Widget build(BuildContext context) {
    final Web3CosmosRequest request = context.getArgruments();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    switch (request.params.method) {
      case Web3CosmosRequestMethods.addNewChain:
        return CosmosWeb3GlobalFieldsView<bool, Web3CosmosAddNewChain>(
            request: request.cast(), wallet: wallet);
      case Web3CosmosRequestMethods.requestAccounts:
        return CosmosWeb3GlobalFieldsView(request: request, wallet: wallet);
      case Web3CosmosRequestMethods.signMessage:
        return CosmosWeb3GlobalFieldsView<Web3CosmosSignMessageResponse,
            Web3CosmosSignMessage>(request: request.cast(), wallet: wallet);
      case Web3CosmosRequestMethods.signTransactionAmino:
      case Web3CosmosRequestMethods.signTransactionDirect:
        return CosmosWeb3TransactionFieldsView(
            request: request.cast(), wallet: wallet);
      case Web3CosmosRequestMethods.switchNetwork:
        return CosmosWeb3GlobalFieldsView(request: request, wallet: wallet);
      default:
    }
    return WidgetConstant.sizedBox;
  }
}
