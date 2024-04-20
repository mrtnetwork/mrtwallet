import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/cosmos/cosmos.dart';

import 'package:mrt_wallet/provider/transaction_validator/transaction_validator.dart';

import 'transaction.dart';

class CosmosTransferTransactionView extends StatelessWidget {
  const CosmosTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppChain? token = context.getNullArgruments();
    return CosmosTransactionFieldsView(
        field: LiveTransactionValidator(
            validator: CosmosTransferValidator(
                network: token!.network as APPCosmosNetwork)));
  }
}
