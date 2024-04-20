import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/live_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/solana/core/solana_transaction_validator.dart';
import 'package:on_chain/solana/src/instructions/memo/program.dart';

abstract class SolanaTransactionImpl extends StateController {
  SolanaTransactionImpl(
      {required this.walletProvider,
      required this.account,
      required this.network,
      required this.address,
      required this.apiProvider,
      required this.validator});
  final WalletProvider walletProvider;
  final NetworkAccountCore account;
  final APPSolanaNetwork network;
  final SolanaApiProvider apiProvider;
  final ISolanaAddress address;
  ISolanaAddress get owner => address;
  final LiveTransactionValidator<SolanaTransactionValidator> validator;
  MemoProgram? get memo;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_SolanaTransactionImpl");
  void onChange();
}
