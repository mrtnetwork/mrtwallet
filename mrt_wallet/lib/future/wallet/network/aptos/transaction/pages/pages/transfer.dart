import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/wallet/models/token/chains_tokens/aptos.dart';
import 'transaction.dart';

class AptosTransferTransactionView extends StatelessWidget {
  const AptosTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AptosFATokens? token = context.getNullArgruments();
    return AptosTransactionFieldsView(
        field: LiveTransactionForm(validator: AptosTransferForm(token)));
  }
}
