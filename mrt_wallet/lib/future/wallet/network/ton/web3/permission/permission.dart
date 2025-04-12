import 'package:flutter/material.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';
import 'package:ton_dart/ton_dart.dart';

class TonWeb3PermissionView extends StatefulWidget {
  const TonWeb3PermissionView({required this.application, super.key});
  final Web3APPAuthentication application;

  @override
  State<TonWeb3PermissionView> createState() => _TonWeb3PermissionViewState();
}

class _TonWeb3PermissionViewState extends State<TonWeb3PermissionView>
    with
        SafeState,
        Web3PermissionState<
            TonWeb3PermissionView,
            TonAddress,
            TheOpenNetworkChain,
            ITonAddress,
            Web3TonChainAccount,
            Web3TonChain> {
  @override
  Web3APPAuthentication get application => widget.application;
  @override
  Web3TonChainAccount createNewAccountPermission(
      ITonAddress address, bool isDefault) {
    return Web3TonChainAccount.fromChainAccount(
        address: address,
        id: chain.network.value,
        isDefault: isDefault,
        network: chain.network.coinParam.chain);
  }

  @override
  Web3TonChain createNewChainPermission() {
    return Web3TonChain.create(id: chain.network.value);
  }

  @override
  NetworkType get type => NetworkType.ton;

  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<TonAddress, TheOpenNetworkChain,
        ITonAddress, Web3TonChainAccount>(
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
