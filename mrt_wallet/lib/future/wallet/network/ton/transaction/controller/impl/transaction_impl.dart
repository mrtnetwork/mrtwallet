import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:ton_dart/ton_dart.dart';

abstract class TonTransactionImpl extends StateController {
  TonTransactionImpl(
      {required this.walletProvider,
      required this.account,
      required this.network,
      required this.address,
      required this.apiProvider,
      required this.validator});
  final WalletProvider walletProvider;
  final TheOpenNetworkChain account;
  final WalletTonNetwork network;
  final TonClient apiProvider;
  final ITonAddress address;
  final LiveTransactionForm<TonTransactionForm> validator;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_TonTransactionImpl");
  void onChange();
  Future<Message> buildTransaction({bool fakeSignature = false});
}
