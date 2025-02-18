import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/permission/permission.dart';
import 'package:on_chain/aptos/aptos.dart';

class AptosWeb3PermissionView extends StatefulWidget {
  const AptosWeb3PermissionView(
      {required this.permission, required this.application, super.key});
  final Web3AptosChain? permission;
  final Web3APPAuthentication application;

  @override
  State<AptosWeb3PermissionView> createState() =>
      _AptosWeb3PermissionViewState();
}

class _AptosWeb3PermissionViewState extends State<AptosWeb3PermissionView>
    with
        SafeState,
        Web3PermissionState<AptosWeb3PermissionView, AptosAddress, AptosChain,
            IAptosAddress, Web3AptosChainAccount, Web3AptosChain> {
  @override
  Web3APPAuthentication get application => widget.application;
  @override
  Web3AptosChainAccount createNewAccountPermission(IAptosAddress address) {
    return Web3AptosChainAccount.fromChainAccount(
        address: address, id: chain.network.value, isDefault: false);
  }

  @override
  Web3AptosChain createNewChainPermission() {
    return Web3AptosChain.create(id: chain.network.value);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    permission = widget.permission ?? Web3AptosChain.create();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    chains = wallet.wallet.getChains().whereType<AptosChain>().toList();
    chain = permission.getCurrentPermissionChain(chains);
    for (final i in chains) {
      permissions[i] = permission.chainAccounts(i);
    }
    updateActivities();
  }

  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<AptosAddress, AptosChain, IAptosAddress,
            Web3AptosChainAccount>(
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
