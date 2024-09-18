import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';
import 'package:mrt_wallet/future/wallet/network/tron/transaction/pages/pages/tron_transaction_fields.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';

class TronTransferTransactionView extends StatelessWidget {
  const TronTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final TronChain? token = context.getNullArgruments();
    final TronTRC20Token? trc20token = context.getNullArgruments();
    final TronTRC10Token? trc10Token = context.getNullArgruments();
    return TronTransactionFieldsView(
        field: LiveTransactionForm(
            validator: TronTransferForm(
                token: token?.network.coinParam.token ??
                    trc20token?.token ??
                    trc10Token!.token,
                trc20Token: trc20token,
                trc10Token: trc10Token)));
  }
}
