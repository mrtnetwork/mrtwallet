import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/state.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'global.dart';
import 'transaction.dart';

class AptosWeb3FieldsView extends StatelessWidget {
  const AptosWeb3FieldsView({super.key});
  @override
  Widget build(BuildContext context) {
    final Web3AptosRequest request = context.getArgruments();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    switch (request.params.method) {
      case Web3AptosRequestMethods.requestAccounts:
        return AptosWeb3GlobalFieldsView(request: request, wallet: wallet);
      case Web3AptosRequestMethods.signMessage:
        return AptosWeb3GlobalFieldsView<Web3AptosSignMessageResponse,
                Web3AptosSignMessage>(
            request: request as Web3AptosRequest<Web3AptosSignMessageResponse,
                Web3AptosSignMessage>,
            wallet: wallet);
      case Web3AptosRequestMethods.signTransaction:
      case Web3AptosRequestMethods.signAllTransactions:
      case Web3AptosRequestMethods.sendTransaction:
        return AptosWeb3TransactionFieldsView(
            request: request.cast(), wallet: wallet);
      case Web3AptosRequestMethods.switchNetwork:
        return AptosWeb3GlobalFieldsView(request: request, wallet: wallet);
      default:
    }
    return WidgetConstant.sizedBox;
  }
}
