import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/state.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'global.dart';
import 'transaction.dart';

class StellarWeb3FieldsView extends StatelessWidget {
  const StellarWeb3FieldsView({super.key});
  @override
  Widget build(BuildContext context) {
    final Web3StellarRequest request = context.getArgruments();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    switch (request.params.method) {
      case Web3StellarRequestMethods.requestAccounts:
        return StellarWeb3GlobalFieldsView(request: request, wallet: wallet);
      case Web3StellarRequestMethods.signMessage:
        return StellarWeb3GlobalFieldsView<List<int>, Web3StellarSignMessage>(
            request: request
                as Web3StellarRequest<List<int>, Web3StellarSignMessage>,
            wallet: wallet);
      case Web3StellarRequestMethods.signTransaction:
      case Web3StellarRequestMethods.sendTransaction:
        return StellarWeb3TransactionFieldsView(
            request: request.cast(), wallet: wallet);
      default:
    }
    return WidgetConstant.sizedBox;
  }
}
