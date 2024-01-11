import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/fields/ripple_tranaction_fields_view.dart';
import 'package:mrt_wallet/provider/transaction_validator/transaction_validator.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class RippleTransferTransactionView extends StatelessWidget {
  const RippleTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppChain? token = context.getNullArgruments();
    final RippleIssueToken? issueToken = context.getNullArgruments();
    return RippleTransactionFieldsView(
        field: LiveTransactionValidator(
            validator: RipplePaymentValidator(
                issueToken: issueToken,
                token: token?.network.coinParam.token ?? issueToken!.token)));
  }
}
