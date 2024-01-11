import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/transaction/fields/tron_transaction_fields.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/tron/transaction_validator/transfer/transfer.dart';

class TronTransferTransactionView extends StatelessWidget {
  const TronTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppChain? token = context.getNullArgruments();
    final TronTRC20Token? trc20token = context.getNullArgruments();
    final TronTRC10Token? trc10Token = context.getNullArgruments();
    return TronTransactionFieldsView(
        field: LiveTransactionValidator(
            validator: TronTransferValidator(
                token: token?.network.coinParam.token ??
                    trc20token?.token ??
                    trc10Token!.token,
                trc20Token: trc20token,
                trc10Token: trc10Token)));
  }
}
