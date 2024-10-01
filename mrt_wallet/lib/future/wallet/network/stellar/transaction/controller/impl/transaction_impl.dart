import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/page_progress.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'memo.dart';

abstract class StellarTransactionImpl extends StateController {
  StellarTransactionImpl(
      {required this.walletProvider,
      required this.account,
      required this.network,
      required this.address,
      required this.apiProvider});
  StellarAccountResponse get accountInfo;
  final WalletProvider walletProvider;
  final StellarChain account;
  final WalletStellarNetwork network;
  final StellarClient apiProvider;
  final IStellarAddress address;
  void setFee(String? feeType, {BigInt? customFee, DynamicVoid? onError});
  StellarMemoDetils? get memo;
  IntegerBalance? get fee;
  List<StellarTransactionOperation> get customOperations;
  TransactionTimeBound get timebound;

  Future<void> onSetupMemo(OnSetupStellarMemo onSetupMemo);
  void checkTransaction();
  Map<String, IntegerBalance> get fees;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_StellarTransactionImpl");
}
