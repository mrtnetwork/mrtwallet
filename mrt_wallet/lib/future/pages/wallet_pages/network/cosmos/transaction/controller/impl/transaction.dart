import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/widgets/progress_bar/page_progress.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/networks/networks.dart';
import 'package:mrt_wallet/provider/transaction_validator/cosmos/cosmos.dart';
import 'package:mrt_wallet/provider/transaction_validator/transaction_validator.dart';

abstract class CosmosTransactiomImpl extends StateController {
  CosmosTransactiomImpl(
      {required this.walletProvider,
      required this.account,
      required this.network,
      required this.address,
      required this.apiProvider,
      required this.validator});
  final WalletProvider walletProvider;
  final NetworkAccountCore account;
  final APPCosmosNetwork network;
  final CosmosApiProvider apiProvider;
  final ICosmosAddress address;
  final LiveTransactionValidator<CosmosTransactionValidator> validator;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>(debugLabel: "CosmosTransactiomImpl");
  late final NoneDecimalBalance remindAmount =
      NoneDecimalBalance.zero(network.coinParam.decimal);
  BaseAccount get ownerAccount;
  GetLatestBlockResponse get latestBlock;
  ThorNodeNetworkConstants get thorNodeNetworkConstants;
  Fee? get fee;
  String? get memo;
  bool get isThorChain =>
      network.coinParam.networkType == CosmosNetworkTypes.thorAndForked;

  void onCalculateAmount();
  // 8050
}
