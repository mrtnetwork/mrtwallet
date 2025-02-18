import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/solana.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaWeb3PermissionView extends StatefulWidget {
  const SolanaWeb3PermissionView(
      {required this.permission, required this.application, super.key});
  final Web3APPAuthentication application;
  final Web3SolanaChain? permission;

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
  Web3SolanaChainAccount createNewAccountPermission(ISolanaAddress address) {
    return Web3SolanaChainAccount.fromChainAccount(
        address: address, id: chain.network.value, isDefault: false);
  }

  @override
  Web3SolanaChain createNewChainPermission() {
    return Web3SolanaChain.create(id: chain.network.value);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    permission = widget.permission ?? Web3SolanaChain.create();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    chains = wallet.wallet.getChains().whereType<SolanaChain>().toList();
    chain = permission.getCurrentPermissionChain(chains);
    for (final i in chains) {
      permissions[i] = permission.chainAccounts(i);
    }
    updateActivities();
  }

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
