import 'package:flutter/material.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/sui.dart';

import 'package:on_chain/sui/sui.dart';

class SuiWeb3PermissionView extends StatefulWidget {
  const SuiWeb3PermissionView({required this.application, super.key});
  final Web3APPAuthentication application;

  @override
  State<SuiWeb3PermissionView> createState() => _SuiWeb3PermissionViewState();
}

class _SuiWeb3PermissionViewState extends State<SuiWeb3PermissionView>
    with
        SafeState,
        Web3PermissionState<SuiWeb3PermissionView, SuiAddress, SuiChain,
            ISuiAddress, Web3SuiChainAccount, Web3SuiChain> {
  @override
  Web3APPAuthentication get application => widget.application;
  @override
  Web3SuiChainAccount createNewAccountPermission(
      ISuiAddress address, bool isDefault) {
    return Web3SuiChainAccount.fromChainAccount(
        address: address,
        id: chain.network.value,
        isDefault: isDefault,
        network: chain.network.coinParam.suiChain);
  }

  @override
  Web3SuiChain createNewChainPermission() {
    return Web3SuiChain.create(id: chain.network.value);
  }

  @override
  NetworkType get type => NetworkType.sui;

  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<SuiAddress, SuiChain, ISuiAddress,
            Web3SuiChainAccount>(
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
