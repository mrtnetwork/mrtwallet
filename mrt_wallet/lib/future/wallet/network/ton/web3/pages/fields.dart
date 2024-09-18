import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/global/state.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';
import 'global.dart';
import 'transaction.dart';

class TonWeb3FieldsView extends StatelessWidget {
  const TonWeb3FieldsView({super.key});
  @override
  Widget build(BuildContext context) {
    final Web3TonRequest request = context.getArgruments();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    switch (request.params.method) {
      case Web3TonRequestMethods.requestAccounts:
        return TonWeb3GlobalFieldsView(request: request, wallet: wallet);
      case Web3TonRequestMethods.signMessage:
        return TonWeb3GlobalFieldsView<List<int>, Web3TonSignMessage>(
            request: request as Web3TonRequest<List<int>, Web3TonSignMessage>,
            wallet: wallet);
      case Web3TonRequestMethods.sendTransaction:
        return TonWeb3TransactionFieldsView(
            request: request.cast(), wallet: wallet);
      default:
    }
    return WidgetConstant.sizedBox;
  }
}
