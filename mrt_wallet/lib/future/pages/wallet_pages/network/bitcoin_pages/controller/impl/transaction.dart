import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/widgets/progress_bar/page_progress.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/networks/bitcoin/bitcoin_api_provider.dart';

abstract class BitcoinTransactionImpl extends StateController {
  BitcoinTransactionImpl({
    required this.walletProvider,
    required this.chainAccount,
  });
  final WalletProvider walletProvider;
  final AppChain chainAccount;
  AppBitcoinNetwork get network => chainAccount.network as AppBitcoinNetwork;
  List<IBitcoinAddress> get addresses => chainAccount.account.addresses.cast();
  NetworkAccountCore get account => chainAccount.account;
  late final BitcoinApiProvider apiProvider = chainAccount.provider();
  String? get memo;
  setFee(BitcoinFeeRateType? feeType, {BigInt? customFee});
  onCalculateAmount();
  NoneDecimalBalance get transactionFee;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey(debugLabel: "BitcoinTransactionPages");
}
