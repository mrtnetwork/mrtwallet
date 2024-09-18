import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';
import 'package:ton_dart/ton_dart.dart';

class TonWeb3PermissionView extends StatefulWidget {
  const TonWeb3PermissionView({required this.permission, Key? key})
      : super(key: key);
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
  Web3TonChainAccount createNewAccountPermission(ITonAddress address) {
    return Web3TonChainAccount.fromChainAccount(
        address: address,
        workChain: chain.network.coinParam.workchain,
        isDefault: false);
  }

  @override
  Web3TonChain createNewChainPermission() {
    return Web3TonChain.create(workChain: chain.network.coinParam.workchain);
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    permission = widget.permission ?? Web3TonChain.create();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    chains =
        wallet.wallet.getChains().whereType<TheOpenNetworkChain>().toList();
    for (final i in chains) {
      permissions[i] = permission.chainAccounts(i);
    }
    chain = chains.firstWhere(
        (e) => e.network.coinParam.workchain == permission.currentChain,
        orElse: () => chains.first);
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
        onChangeDefaultAccount: onChangeDefaultPermission);
  }
}
