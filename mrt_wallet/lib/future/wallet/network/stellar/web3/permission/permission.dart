import 'package:flutter/material.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarWeb3PermissionView extends StatefulWidget {
  const StellarWeb3PermissionView({required this.application, super.key});
  final Web3APPAuthentication application;

  @override
  State<StellarWeb3PermissionView> createState() =>
      _StellarWeb3PermissionViewState();
}

class _StellarWeb3PermissionViewState extends State<StellarWeb3PermissionView>
    with
        SafeState,
        Web3PermissionState<
            StellarWeb3PermissionView,
            StellarAddress,
            StellarChain,
            IStellarAddress,
            Web3StellarChainAccount,
            Web3StellarChain> {
  @override
  Web3APPAuthentication get application => widget.application;
  @override
  Web3StellarChainAccount createNewAccountPermission(
      IStellarAddress address, bool isDefault) {
    return Web3StellarChainAccount.fromChainAccount(
        address: address,
        id: chain.network.value,
        isDefault: isDefault,
        network: chain.network.coinParam.stellarChainType);
  }

  @override
  Web3StellarChain createNewChainPermission() {
    return Web3StellarChain.create(id: chain.network.value);
  }

  @override
  NetworkType get type => NetworkType.stellar;

  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<StellarAddress, StellarChain,
        IStellarAddress, Web3StellarChainAccount>(
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
