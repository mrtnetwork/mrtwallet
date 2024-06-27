import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:on_chain/tron/src/provider/models/chain_parameters.dart';

abstract class TronTransactionImpl extends StateController {
  TronTransactionImpl(
      {required this.walletProvider,
      required this.account,
      required this.network,
      required this.address,
      required this.apiProvider});
  TronChainParameters get tronChainParameters;
  TronTransactionForm get field;
  final WalletProvider walletProvider;
  final NetworkAccountCore account;
  final WalletTronNetwork network;
  final TronClient apiProvider;
  final ITronAddress address;
  ITronAddress get owner => address;
  String? get memo;
  TronFee? get consumedFee;
  final GlobalKey<PageProgressState> progressKey = GlobalKey<PageProgressState>(
      debugLabel: "progressKey_EthTransactionImpl");
}
