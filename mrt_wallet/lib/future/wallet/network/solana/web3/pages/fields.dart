import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/state.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'global.dart';
import 'transaction.dart';

class SolanaWeb3FieldsView extends StatelessWidget {
  const SolanaWeb3FieldsView({super.key});
  @override
  Widget build(BuildContext context) {
    final Web3SolanaRequest request = context.getArgruments();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    switch (request.params.method) {
      case Web3SolanaRequestMethods.requestAccounts:
        return SolanaWeb3GlobalFieldsView(request: request, wallet: wallet);
      case Web3SolanaRequestMethods.signMessage:
        return SolanaWeb3GlobalFieldsView<Web3SolanaSignMessageResponse,
                Web3SolanaSignMessage>(
            request: request as Web3SolanaRequest<Web3SolanaSignMessageResponse,
                Web3SolanaSignMessage>,
            wallet: wallet);
      case Web3SolanaRequestMethods.signTransaction:
      case Web3SolanaRequestMethods.signAllTransactions:
      case Web3SolanaRequestMethods.sendTransaction:
      case Web3SolanaRequestMethods.sendAllTransactions:
        return SolanaWeb3TransactionFieldsView(
            request: request.cast(), wallet: wallet);
      default:
    }
    return WidgetConstant.sizedBox;
  }
}
