import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/ethereum/ethereum.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/etherum.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';

class EthereumWeb3PermissionView extends StatefulWidget {
  const EthereumWeb3PermissionView({required this.permission, Key? key})
      : super(key: key);
  final Web3EthereumChain? permission;

  @override
  State<EthereumWeb3PermissionView> createState() =>
      _EthereumWeb3PermissionViewState();
}

class _EthereumWeb3PermissionViewState extends State<EthereumWeb3PermissionView>
    with
        SafeState,
        Web3PermissionState<
            EthereumWeb3PermissionView,
            ETHAddress,
            EthereumChain,
            IEthAddress,
            Web3EthereumChainAccount,
            Web3EthereumChain> {
  @override
  Web3EthereumChain createNewChainPermission() {
    return Web3EthereumChain.create(chainId: chain.chainId);
  }

  @override
  Web3EthereumChainAccount createNewAccountPermission(IEthAddress address) {
    return Web3EthereumChainAccount.fromChainAccount(
        address: address, chainId: chain.chainId, defaultAddress: false);
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    permission = widget.permission ?? Web3EthereumChain.create();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    chains = wallet.wallet.getChains().whereType<EthereumChain>().toList();
    for (final i in chains) {
      permissions[i] = permission.chainAccounts(i);
    }
    chain = chains.firstWhere((e) => e.chainId == permission.currentChain,
        orElse: () => chains.first);
  }

  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<ETHAddress, EthereumChain, IEthAddress,
        Web3EthereumChainAccount>(
      chain: chain,
      chains: chains,
      onUpdateState: updateState,
      hasPermission: hasPermission,
      addAccount: addAccount,
      onChangeChain: onChangeChain,
      onChangeDefaultAccount: onChangeDefaultPermission,
    );
  }
}
