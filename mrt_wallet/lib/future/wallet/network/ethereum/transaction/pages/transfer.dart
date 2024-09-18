import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';

import 'transaction.dart';

class EthereumTransferTransactionView extends StatelessWidget {
  const EthereumTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final EthereumChain? token = context.getNullArgruments();
    final ETHERC20Token? erc20Token = context.getNullArgruments();
    return EthereumTransactionFieldsView(
        field: LiveTransactionForm(
            validator: EthereumTransferForm(
                token: token?.network.coinParam.token ?? erc20Token!.token,
                erc20Token: erc20Token)));
  }
}
