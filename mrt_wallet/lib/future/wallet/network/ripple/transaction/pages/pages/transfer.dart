import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/network/ripple/transaction/pages/pages/ripple_tranaction_fields_view.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class RippleTransferTransactionView extends StatelessWidget {
  const RippleTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final RippleChain? token = context.getNullArgruments();
    final RippleIssueToken? issueToken = context.getNullArgruments();
    return RippleTransactionFieldsView(
        field: LiveTransactionForm(
            validator: RipplePaymentForm(
                issueToken: issueToken,
                token: token?.network.coinParam.token ?? issueToken!.token)));
  }
}
