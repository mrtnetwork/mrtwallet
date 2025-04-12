import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

abstract class CosmosAccountState<W extends StatefulWidget>
    extends ChainAccountState<
        W,
        CosmosAPIProvider,
        CosmosBaseAddress,
        CW20Token,
        NFTCore,
        ICosmosAddress,
        CosmosClient,
        CosmosChain,
        WalletTransaction<CosmosBaseAddress>> {
  List<CosmosIBCChannelId> accountChannelIds = [];

  Future<List<CosmosIBCChannelId>> getAccountIbcChannels() async {
    final channels = await account.loadChannelIds();
    accountChannelIds = channels.immutable;
    return accountChannelIds;
  }

  @override
  void safeDispose() {
    super.safeDispose();
    accountChannelIds = [];
  }
}
