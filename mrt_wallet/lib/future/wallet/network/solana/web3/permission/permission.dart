import 'package:flutter/material.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/solana.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaWeb3PermissionView extends StatefulWidget {
  const SolanaWeb3PermissionView({required this.application, super.key});
  final Web3APPAuthentication application;

  @override
  State<SolanaWeb3PermissionView> createState() =>
      _SolanaWeb3PermissionViewState();
}

class _SolanaWeb3PermissionViewState extends State<SolanaWeb3PermissionView>
    with
        SafeState,
        Web3PermissionState<SolanaWeb3PermissionView, SolAddress, SolanaChain,
            ISolanaAddress, Web3SolanaChainAccount, Web3SolanaChain> {
  @override
  Web3APPAuthentication get application => widget.application;
  @override
  Web3SolanaChainAccount createNewAccountPermission(
      ISolanaAddress address, bool isDefault) {
    return Web3SolanaChainAccount.fromChainAccount(
        address: address,
        id: chain.network.value,
        isDefault: isDefault,
        network: chain.network.coinParam.type);
  }

  @override
  Web3SolanaChain createNewChainPermission() {
    return Web3SolanaChain.create(id: chain.network.value);
  }

  @override
  NetworkType get type => NetworkType.solana;

  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<SolAddress, SolanaChain, ISolanaAddress,
        Web3SolanaChainAccount>(
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
