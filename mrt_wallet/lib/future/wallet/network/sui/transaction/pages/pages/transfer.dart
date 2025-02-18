import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'transaction.dart';

class SuiTransferTransactionView extends StatelessWidget {
  const SuiTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final SuiToken? token = context.getNullArgruments();
    return SuiTransactionFieldsView(
        field: LiveTransactionForm(validator: SuiTransferForm(token)));
  }
}
