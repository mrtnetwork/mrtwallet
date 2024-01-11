import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/pages/start_page/home.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/tron/transaction_validator/core/tron_field_validator.dart';
import 'package:mrt_wallet/provider/api/networks/tron/tron_api_provider.dart';
import 'package:on_chain/tron/provider/models/chain_parameters.dart';

abstract class TronTransactionImpl extends StateController {
  TronTransactionImpl(
      {required this.walletProvider,
      required this.account,
      required this.network,
      required this.address,
      required this.apiProvider});
  TronChainParameters get tronChainParameters;
  TronTransactionValidator get field;
  final WalletProvider walletProvider;
  final NetworkAccountCore account;
  final APPTVMNetwork network;
  final TVMApiProvider apiProvider;
  final ITronAddress address;
  ITronAddress get owner => address;
  String? get memo;
  TronFee? get consumedFee;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_EthTransactionImpl");
}
