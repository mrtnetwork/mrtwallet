import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/solana/solana.dart';
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
  final SolanaChain account;
  final WalletSolanaNetwork network;
  final SolanaClient apiProvider;
  final ISolanaAddress address;
  final LiveTransactionForm<SolanaTransactionForm> validator;
  ISolanaAddress get owner => address;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_SolanaTransactionImpl");

  void onChange();
  MemoProgram? get memo;
}
