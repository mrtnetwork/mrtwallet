import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'transaction.dart';

class SubstrateTransferTransactionView extends StatelessWidget {
  const SubstrateTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final SubstrateChain chain = context.getArgruments();
    return SubstrateTransactionFieldsView(
        field: LiveTransactionForm(
            validator: SubstrateTransferForm(network: chain.network)));
  }
}
