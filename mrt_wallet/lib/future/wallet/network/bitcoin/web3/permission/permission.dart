import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';
import 'package:mrt_wallet/wallet/web3/networks/bitcoin/bitcoin.dart';

class BitcoinWeb3PermissionView extends StatefulWidget {
  const BitcoinWeb3PermissionView({required this.application, super.key});
  final Web3APPAuthentication application;

  @override
  State<BitcoinWeb3PermissionView> createState() =>
      _BitcoinWeb3PermissionViewState();
}

class _BitcoinWeb3PermissionViewState extends State<BitcoinWeb3PermissionView>
    with
        SafeState,
        Web3PermissionState<
            BitcoinWeb3PermissionView,
            BitcoinBaseAddress,
            BitcoinChain,
            IBitcoinAddress,
            Web3BitcoinChainAccount,
            Web3BitcoinChain> {
  @override
  Web3APPAuthentication get application => widget.application;
  @override
  Web3BitcoinChainAccount createNewAccountPermission(
      IBitcoinAddress address, bool isDefault) {
    return Web3BitcoinChainAccount.fromChainAccount(
        address: address, network: chain.network, isDefault: isDefault);
  }

  @override
  Web3BitcoinChain createNewChainPermission() {
    return Web3BitcoinChain.create(id: chain.network.value);
  }

  @override
  NetworkType get type => NetworkType.bitcoinAndForked;

  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<BitcoinBaseAddress, BitcoinChain,
            IBitcoinAddress, Web3BitcoinChainAccount>(
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
