import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:on_chain/aptos/src/transaction/types/types.dart';

abstract class AptosTransactionImpl extends StateController {
  AptosTransactionImpl(
      {required this.walletProvider,
      required this.account,
      required this.validator});
  final WalletProvider walletProvider;
  final AptosChain account;
  WalletAptosNetwork get network => account.network;
  AptosClient get apiProvider => account.client;
  IAptosAddress get address => account.address;
  final LiveTransactionForm<AptosTransactionForm> validator;
  AptosTransactionForm get form => validator.validator;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_SolanaTransactionImpl");
  void checkTransaction();
  Future<AptosSignedTransaction> createTransaction(
      {BigInt? maxGasAmount, BigInt? gasUnitPrice, bool simulateTx = false});
}
