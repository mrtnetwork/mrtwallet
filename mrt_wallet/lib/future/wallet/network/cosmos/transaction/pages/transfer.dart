import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';

import 'transaction.dart';

class CosmosTransferTransactionView extends StatelessWidget {
  const CosmosTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final CosmosChain? token = context.getNullArgruments();
    return CosmosTransactionFieldsView(
        field: LiveTransactionForm(
            validator: CosmosTransferForm(network: token!.network)));
  }
}
