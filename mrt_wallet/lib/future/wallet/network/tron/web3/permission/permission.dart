import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:on_chain/tron/src/address/tron_address.dart';

class TronWeb3PermissionView extends StatefulWidget {
  const TronWeb3PermissionView(
      {required this.permission, required this.application, super.key});
  final Web3APPAuthentication application;
  final Web3TronChain? permission;

  @override
  State<TronWeb3PermissionView> createState() => _TronWeb3PermissionViewState();
}

class _TronWeb3PermissionViewState extends State<TronWeb3PermissionView>
    with
        SafeState,
        Web3PermissionState<TronWeb3PermissionView, TronAddress, TronChain,
            ITronAddress, Web3TronChainAccount, Web3TronChain> {
  @override
  Web3APPAuthentication get application => widget.application;
  @override
  Web3TronChainAccount createNewAccountPermission(ITronAddress address) {
    return Web3TronChainAccount.fromChainAccount(
        address: address, id: chain.network.value, isDefault: false);
  }

  @override
  Web3TronChain createNewChainPermission() {
    return Web3TronChain.create(id: chain.network.value);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    permission = widget.permission ?? Web3TronChain.create();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    chains = wallet.wallet.getChains().whereType<TronChain>().toList();
    chain = permission.getCurrentPermissionChain(chains);
    for (final i in chains) {
      permissions[i] = permission.chainAccounts(i);
    }
    updateActivities();
  }

  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<TronAddress, TronChain, ITronAddress,
            Web3TronChainAccount>(
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
