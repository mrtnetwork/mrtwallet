import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/page_progress.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

abstract class SubstrateTransactiomImpl extends StateController {
  SubstrateTransactiomImpl(
      {required this.walletProvider,
      required this.account,
      required this.network,
      required this.address,
      required this.apiProvider,
      required this.validator});

  final WalletProvider walletProvider;
  final SubstrateChain account;
  final WalletPolkadotNetwork network;
  final SubstrateClient apiProvider;
  final ISubstrateAddress address;
  final LiveTransactionForm<SubstrateTransactionForm> validator;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "SubstrateTransactiomImpl");
  late final IntegerBalance remindAmount =
      IntegerBalance.zero(network.coinParam.decimal);
  List<String> get memos;
  void onCalculateAmount();
  MetadataApi get api => apiProvider.api;
  Future<TransactionPayload> buildTransaction();
}
