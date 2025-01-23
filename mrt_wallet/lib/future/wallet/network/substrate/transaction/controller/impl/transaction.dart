import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/page_progress.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

abstract class SubstrateTransactiomImpl extends StateController {
  SubstrateTransactiomImpl(
      {required this.walletProvider, required this.account});

  final WalletProvider walletProvider;
  final SubstrateChain account;
  WalletSubstrateNetwork get network => account.network;
  SubstrateClient get apiProvider => account.client;
  ISubstrateAddress get address => account.address;
  bool get supportBatch => apiProvider.metadata.supportBatch;
  bool get supportMemo => apiProvider.metadata.supportRemarks;

  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "SubstrateTransactiomImpl");
  late final IntegerBalance remindAmount =
      IntegerBalance.zero(network.coinParam.decimal);
  List<String> get memos;
  void onCalculateAmount();
  MetadataApi get api => apiProvider.api;
}
