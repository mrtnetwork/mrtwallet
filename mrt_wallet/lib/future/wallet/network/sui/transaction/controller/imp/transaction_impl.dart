import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:on_chain/solana/src/instructions/memo/program.dart';
import 'package:on_chain/sui/sui.dart';

abstract class SuiTransactionImpl extends StateController {
  SuiTransactionImpl(
      {required this.walletProvider,
      required this.account,
      required this.validator});
  final WalletProvider walletProvider;
  final SuiChain account;
  WalletSuiNetwork get network => account.network;
  SuiClient get apiProvider => account.client;
  ISuiAddress get address => account.address;
  final LiveTransactionForm<SuiTransactionForm> validator;
  SuiTransactionForm get form => validator.validator;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_SolanaTransactionImpl");
  MemoProgram? get memo;
  void checkTransaction();

  Future<SuiTransactionDataV1> createEstimateTransaction(
      {required BigInt gasPrice, required BigInt budget});
}
