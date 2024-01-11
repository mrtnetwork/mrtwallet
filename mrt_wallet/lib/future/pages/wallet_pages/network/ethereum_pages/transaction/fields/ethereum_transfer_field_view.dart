import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

import 'package:mrt_wallet/provider/transaction_validator/transaction_validator.dart';

import 'ethereum_transaction_fields_view.dart';

class EthereumTransferTransactionView extends StatelessWidget {
  const EthereumTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppChain? token = context.getNullArgruments();
    final ETHERC20Token? erc20Token = context.getNullArgruments();
    return EthereumTransactionFieldsView(
        field: LiveTransactionValidator(
            validator: EthereumTransferValidator(
                token: token?.network.coinParam.token ?? erc20Token!.token,
                erc20Token: erc20Token)));
  }
}
