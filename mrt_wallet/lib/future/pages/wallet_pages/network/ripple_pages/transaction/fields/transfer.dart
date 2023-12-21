import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/fields/ripple_tranaction_fields_view.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/token/networks/ripple/ripple_issue_token.dart';

class RippleTransferTransactionView extends StatelessWidget {
  const RippleTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final RippleIssueToken? token = context.getNullArgruments();
    return RippleTransactionFieldsView(
        field: LiveTransactionValidator(
            validator: RipplePaymentValidator(issueToken: token)));
  }
}
