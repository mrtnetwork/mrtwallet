import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/cosmos.dart';

class CosmosWeb3PermissionView extends StatefulWidget {
  const CosmosWeb3PermissionView({required this.application, super.key});
  final Web3APPAuthentication application;

  @override
  State<CosmosWeb3PermissionView> createState() =>
      _CosmosWeb3PermissionViewState();
}

class _CosmosWeb3PermissionViewState extends State<CosmosWeb3PermissionView>
    with
        SafeState,
        Web3PermissionState<
            CosmosWeb3PermissionView,
            CosmosBaseAddress,
            CosmosChain,
            ICosmosAddress,
            Web3CosmosChainAccount,
            Web3CosmosChain> {
  @override
  Web3APPAuthentication get application => widget.application;
  @override
  Web3CosmosChainAccount createNewAccountPermission(
      ICosmosAddress address, bool isDefault) {
    return Web3CosmosChainAccount.fromChainAccount(
        address: address, id: chain.network.value, isDefault: isDefault);
  }

  @override
  Web3CosmosChain createNewChainPermission() {
    return Web3CosmosChain.create(id: chain.network.value);
  }

  @override
  NetworkType get type => NetworkType.cosmos;
  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<CosmosBaseAddress, CosmosChain,
            ICosmosAddress, Web3CosmosChainAccount>(
        chain: chain,
        chains: chains,
        onUpdateState: updateState,
        hasPermission: hasPermission,
        addAccount: addAccount,
        onChangeChain: onChangeChain,
        onChangeDefaultAccount: onChangeDefaultPermission,
        activities: activities);
  }
}
