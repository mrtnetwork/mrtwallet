import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/live_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/ton/transaction_validator/validator.dart';
import 'transaction.dart';

class TonTransferTransactionView extends StatelessWidget {
  const TonTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppChain chain = context.getArgruments();
    return TonTransactionFieldsView(
        field: LiveTransactionValidator(
            validator:
                TonTransferValidator(network: chain.network.toNetwork())));
  }
}
