import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/live_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/ton/transaction_validator/core/core.dart';
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
  final NetworkAccountCore<BigInt, BigInt, TonAddress> account;
  final APPTonNetwork network;
  final TonApiProvider apiProvider;
  final ITonAddress address;
  final LiveTransactionValidator<TonTransactionValidator> validator;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_TonTransactionImpl");
  void onChange();
  Future<Message> buildTransaction({bool fakeSignature = false});
}
