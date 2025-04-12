import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/state.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'global.dart';
import 'transaction.dart';

class BitcoinWeb3FieldsView extends StatelessWidget {
  const BitcoinWeb3FieldsView({super.key});
  @override
  Widget build(BuildContext context) {
    final Web3BitcoinRequest request = context.getArgruments();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    switch (request.params.method) {
      case Web3BitcoinRequestMethods.requestAccounts:
        return BitcoinWeb3GlobalFieldsView(request: request, wallet: wallet);
      case Web3BitcoinRequestMethods.signPersonalMessage:
        return BitcoinWeb3GlobalFieldsView<Web3BitcoinSignMessageResponse,
            Web3BitcoinSignMessage>(request: request.cast(), wallet: wallet);
      case Web3BitcoinRequestMethods.sendTransaction:
      case Web3BitcoinRequestMethods.signTransaction:
        return BitcoinWeb3TransactionFieldsView(
            request: request.cast(), wallet: wallet);
      default:
    }
    return WidgetConstant.sizedBox;
  }
}
