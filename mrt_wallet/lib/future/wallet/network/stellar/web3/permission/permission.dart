import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarWeb3PermissionView extends StatefulWidget {
  const StellarWeb3PermissionView({required this.permission, Key? key})
      : super(key: key);
  final Web3StellarChain? permission;

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
  Web3StellarChainAccount createNewAccountPermission(IStellarAddress address) {
    return Web3StellarChainAccount.fromChainAccount(
        address: address,
        passphrase: chain.network.coinParam.passphrase,
        isDefault: false);
  }

  @override
  Web3StellarChain createNewChainPermission() {
    return Web3StellarChain.create(
        passphrase: chain.network.coinParam.passphrase);
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    permission = widget.permission ?? Web3StellarChain.create();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    chains = wallet.wallet.getChains().whereType<StellarChain>().toList();
    for (final i in chains) {
      permissions[i] = permission.chainAccounts(i);
    }
    chain = chains.firstWhere(
        (e) => e.network.coinParam.passphrase == permission.currentChain,
        orElse: () => chains.first);
  }

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
        onChangeDefaultAccount: onChangeDefaultPermission);
  }
}
