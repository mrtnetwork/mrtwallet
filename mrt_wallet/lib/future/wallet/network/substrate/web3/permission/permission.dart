import 'package:flutter/material.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateWeb3PermissionView extends StatefulWidget {
  const SubstrateWeb3PermissionView({required this.application, super.key});
  final Web3APPAuthentication application;

  @override
  State<SubstrateWeb3PermissionView> createState() =>
      _SubstrateWeb3PermissionViewState();
}

class _SubstrateWeb3PermissionViewState
    extends State<SubstrateWeb3PermissionView>
    with
        SafeState,
        Web3PermissionState<
            SubstrateWeb3PermissionView,
            BaseSubstrateAddress,
            SubstrateChain,
            ISubstrateAddress,
            Web3SubstrateChainAccount,
            Web3SubstrateChain> {
  @override
  Web3APPAuthentication get application => widget.application;
  @override
  Web3SubstrateChainAccount createNewAccountPermission(
      ISubstrateAddress address, bool isDefault) {
    return Web3SubstrateChainAccount.fromChainAccount(
        address: address, id: chain.network.value, isDefault: isDefault);
  }

  @override
  Web3SubstrateChain createNewChainPermission() {
    return Web3SubstrateChain.create(id: chain.network.value);
  }

  @override
  NetworkType get type => NetworkType.substrate;

  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<BaseSubstrateAddress, SubstrateChain,
        ISubstrateAddress, Web3SubstrateChainAccount>(
      chain: chain,
      chains: chains,
      onUpdateState: updateState,
      hasPermission: hasPermission,
      addAccount: addAccount,
      onChangeChain: onChangeChain,
      onChangeDefaultAccount: onChangeDefaultPermission,
      activities: activities,
    );
  }
}
