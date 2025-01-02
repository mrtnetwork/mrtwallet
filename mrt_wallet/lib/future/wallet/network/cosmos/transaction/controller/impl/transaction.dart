import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/page_progress.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';

abstract class CosmosTransactiomImpl extends StateController {
  CosmosTransactiomImpl(
      {required this.walletProvider,
      required this.account,
      required this.validator});

  final WalletProvider walletProvider;
  final CosmosChain account;
  WalletCosmosNetwork get network => account.network;
  late final CosmosClient apiProvider = account.client;
  ICosmosAddress get address => account.address;
  final LiveTransactionForm<CosmosTransactionForm> validator;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "CosmosTransactiomImpl");
  late final IntegerBalance remindAmount =
      IntegerBalance.zero(network.coinParam.decimal);

  BaseAccount get ownerAccount;
  GetLatestBlockResponse get latestBlock;
  CosmosTransactionFeeInfo? get fee;
  String? get memo;
  bool get isThorChain =>
      network.coinParam.networkType == CosmosNetworkTypes.thorAndForked;
  Token get feeToken;
  List<CW20Token> get feeTokens;
  bool get useNativeTokenAsFee => network.coinParam.useNativeTokenAsFee;

  void onCalculateAmount();

  // 8050
}
