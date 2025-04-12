import 'package:flutter/material.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/ethereum/ethereum.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/etherum.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';

import '../../../../../../wallet/web3/core/permission/models/authenticated.dart';

class EthereumWeb3PermissionView extends StatefulWidget {
  const EthereumWeb3PermissionView({required this.application, super.key});
  final Web3APPAuthentication application;

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
  Web3APPAuthentication get application => widget.application;
  @override
  Web3EthereumChain createNewChainPermission() {
    return Web3EthereumChain.create(id: chain.network.value);
  }

  @override
  Web3EthereumChainAccount createNewAccountPermission(
      IEthAddress address, bool isDefault) {
    return Web3EthereumChainAccount.fromChainAccount(
        address: address, id: chain.network.value, defaultAddress: isDefault);
  }

  @override
  NetworkType get type => NetworkType.ethereum;

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
      activities: activities,
    );
  }
}
