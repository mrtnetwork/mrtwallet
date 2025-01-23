import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateWeb3PermissionView extends StatefulWidget {
  const SubstrateWeb3PermissionView({required this.permission, super.key});
  final Web3SubstrateChain? permission;

  @override
  State<SubstrateWeb3PermissionView> createState() =>
      _SubstrateWeb3PermissionViewState();
}

class _SubstrateWeb3PermissionViewState
    extends State<SubstrateWeb3PermissionView>
    with
        SafeState,
        Web3PermissionState<
            SubstrateWeb3PermissionView,
            BaseSubstrateAddress,
            SubstrateChain,
            ISubstrateAddress,
            Web3SubstrateChainAccount,
            Web3SubstrateChain> {
  @override
  Web3SubstrateChainAccount createNewAccountPermission(
      ISubstrateAddress address) {
    return Web3SubstrateChainAccount.fromChainAccount(
        address: address,
        genesis: chain.network.genesisBlock,
        isDefault: false);
  }

  @override
  Web3SubstrateChain createNewChainPermission() {
    return Web3SubstrateChain.create(genesis: chain.network.genesisBlock);
  }

  @override
  void onInitOnce() {
    super.onInitOnce();
    permission = widget.permission ?? Web3SubstrateChain.create();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    chains = wallet.wallet.getChains().whereType<SubstrateChain>().toList();
    chain = permission.getCurrentPermissionChain(chains);
    for (final i in chains) {
      permissions[i] = permission.chainAccounts(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<BaseSubstrateAddress, SubstrateChain,
            ISubstrateAddress, Web3SubstrateChainAccount>(
        chain: chain,
        chains: chains,
        onUpdateState: updateState,
        hasPermission: hasPermission,
        addAccount: addAccount,
        onChangeChain: onChangeChain,
        onChangeDefaultAccount: onChangeDefaultPermission);
  }
}
