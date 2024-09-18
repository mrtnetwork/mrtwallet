import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'package:on_chain/tron/src/address/tron_address.dart';

class TronWeb3PermissionView extends StatefulWidget {
  const TronWeb3PermissionView({required this.permission, Key? key})
      : super(key: key);
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
  Web3TronChainAccount createNewAccountPermission(ITronAddress address) {
    return Web3TronChainAccount.fromChainAccount(
        address: address,
        chain: chain.network.tronNetworkType,
        isDefault: false);
  }

  @override
  Web3TronChain createNewChainPermission() {
    return Web3TronChain.create(chain: chain.network.tronNetworkType);
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    permission = widget.permission ?? Web3TronChain.create();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    chains = wallet.wallet.getChains().whereType<TronChain>().toList();
    for (final i in chains) {
      permissions[i] = permission.chainAccounts(i);
    }
    chain = chains.firstWhere(
        (e) => e.network.tronNetworkType == permission.currentChain,
        orElse: () => chains.first);
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
        onChangeDefaultAccount: onChangeDefaultPermission);
  }
}
