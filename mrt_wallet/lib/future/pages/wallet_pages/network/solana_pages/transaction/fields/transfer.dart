import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/chain/chain.dart';
import 'package:mrt_wallet/models/wallet_models/token/token.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/live_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/solana/transfer/transfer.dart';
import 'transaction.dart';

class SolanaTransferTransactionView extends StatelessWidget {
  const SolanaTransferTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppChain? chain = context.getNullArgruments();
    final SolanaSPLToken? splToken = context.getNullArgruments();

    return SolanaTransactionFieldsView(
        field: LiveTransactionValidator(
            validator: SolanaTransferValidator(
                token: chain?.network.coinParam.token ?? splToken!.token,
                splToken: splToken)));
  }
}
