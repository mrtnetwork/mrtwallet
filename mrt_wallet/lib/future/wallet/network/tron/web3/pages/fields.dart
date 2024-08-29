import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/state.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'global.dart';
import 'transaction.dart';

class TronWeb3FieldsView extends StatelessWidget {
  const TronWeb3FieldsView({super.key});
  @override
  Widget build(BuildContext context) {
    final Web3TronRequest request = context.getArgruments();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    switch (request.params.method) {
      case Web3TronRequestMethods.requestAccounts:
        return TronWeb3GlobalFieldsView(request: request, wallet: wallet);
      case Web3TronRequestMethods.signMessageV2:
        return TronWeb3GlobalFieldsView<String, Web3TronSignMessageV2>(
            request: request as Web3TronRequest<String, Web3TronSignMessageV2>,
            wallet: wallet);
      case Web3TronRequestMethods.signTransaction:
        return TronWeb3TransactionFieldsView(
            request: request.cast(), wallet: wallet);
      default:
    }
    return WidgetConstant.sizedBox;
  }
}
