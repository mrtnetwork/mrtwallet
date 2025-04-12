import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'transaction.dart';

class CosmosTransferTransactionView extends StatelessWidget {
  const CosmosTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return CosmosTransactionFieldsView(
        form: LiveTransactionForm(validator: CosmosTransferForm()));
  }
}
