import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';
import 'package:ton_dart/ton_dart.dart';

class TonWeb3PermissionView extends StatefulWidget {
  const TonWeb3PermissionView(
      {required this.permission, required this.application, super.key});
  final Web3APPAuthentication application;
  final Web3TonChain? permission;

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
  Web3TonChainAccount createNewAccountPermission(ITonAddress address) {
    return Web3TonChainAccount.fromChainAccount(
        address: address, id: chain.network.value, isDefault: false);
  }

  @override
  Web3TonChain createNewChainPermission() {
    return Web3TonChain.create(id: chain.network.value);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    permission = widget.permission ?? Web3TonChain.create();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    chains =
        wallet.wallet.getChains().whereType<TheOpenNetworkChain>().toList();
    chain = permission.getCurrentPermissionChain(chains);
    for (final i in chains) {
      permissions[i] = permission.chainAccounts(i);
    }
    updateActivities();
  }

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
