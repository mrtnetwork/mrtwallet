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
  const EthereumWeb3PermissionView(
      {required this.permission,
      required this.onUpdateChainPermission,
      Key? key})
      : super(key: key);
  final Web3EthereumChain? permission;
  final OnUpdateChainPermission onUpdateChainPermission;

  @override
  State<EthereumWeb3PermissionView> createState() =>
      _EthereumWeb3PermissionViewState();
}

class _EthereumWeb3PermissionViewState extends State<EthereumWeb3PermissionView>
    with SafeState {
  late EthereumChain currentChain;
  late Web3EthereumChain permission =
      widget.permission ?? Web3EthereumChain.create();

  late final List<EthereumChain> chains;
  Map<EthereumChain, List<Web3EthereumChainAccount>> permissions = {};
  late EthereumChain chain;

  Map<EthereumChain, Web3EthereumChainAccount> defaultAccount = {};

  List<Web3EthereumChainAccount> get chainPermission => permissions[chain]!;

  Web3EthereumChainAccount? get defaultChainAccount => defaultAccount[chain];

  void onChangeDefaultPermission(Web3EthereumChainAccount? account) {
    if (account == null) return;
    defaultAccount[chain] = account;
    updateState();
  }

  Web3EthereumChainAccount? accountPermission(IEthAddress address) {
    return permissions[chain]!.firstWhereOrNull(
        (e) => e.address.address == address.networkAddress.address);
  }

  Web3EthereumChainAccount? hasPermission(IEthAddress address) {
    return accountPermission(address);
  }

  void addAccount(IEthAddress address) {
    final exists = accountPermission(address);
    if (exists != null) {
      permissions[chain]?.remove(exists);
    } else {
      permissions[chain]?.add(Web3EthereumChainAccount.fromChainAccount(
          address: address, chainId: chain.chainId, defaultAddress: false));
    }
    if (permissions[chain]!.isEmpty) {
      defaultAccount.remove(chain);
    } else {
      if (!permissions[chain]!.contains(defaultChainAccount)) {
        defaultAccount[chain] = permissions[chain]![0];
      }
    }
    updateState();
  }

  void onChangeCurrentChain(EthereumChain? chain) {
    if (chain == null) return;
    currentChain = chain;
    updateState();
  }

  void onChangeChain(EthereumChain? updateChain) {
    chain = updateChain ?? chain;
    updateState();
  }

  void complete() {
    final newPermission =
        Web3EthereumChain.create(chainId: currentChain.chainId);
    List<Web3EthereumChainAccount> accounts = [];
    for (final i in permissions.entries) {
      List<Web3EthereumChainAccount> chainAccounts = [];
      Web3EthereumChainAccount? defaultAddr = defaultAccount[i.key];
      defaultAddr ??= i.value.isEmpty ? null : i.value.first;
      for (final a in i.value) {
        Web3EthereumChainAccount account = a;
        if (account == defaultAddr && !account.defaultAddress) {
          account = account.changeDefault(true);
        } else if (account.defaultAddress) {
          account = account.changeDefault(false);
        }
        chainAccounts.add(account);
      }
      if (chainAccounts.isNotEmpty &&
          !chainAccounts.any((e) => e.defaultAddress)) {
        chainAccounts[0] = chainAccounts[0].changeDefault(true);
      }
      accounts.addAll(chainAccounts);
    }
    newPermission.updateChainAccount(accounts);
    widget.onUpdateChainPermission(newPermission);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wallet = context.watch<WalletProvider>(StateConst.main);
    chains = wallet.wallet.getChains().whereType<EthereumChain>().toList();
    currentChain = chains.firstWhere(
        (e) => e.chainId == permission.currentChain,
        orElse: () => chains.first);
    for (final i in chains) {
      permissions[i] = permission.accounts
          .where((e) => e.chainId == i.network.coinParam.chainId)
          .toList();
    }
    chain = chains.firstWhere((e) => e.chainId == currentChain.chainId);
    final Map<EthereumChain, Web3EthereumChainAccount> defaultAccount = {};
    for (final i in chains) {
      final accounts = permissions[i]!;
      final defaultAddress = accounts.firstWhereOrNull((e) => e.defaultAddress);
      if (defaultAddress != null) {
        defaultAccount[i] = defaultAddress;
      }
    }
    this.defaultAccount = defaultAccount;
  }

  @override
  Widget build(BuildContext context) {
    return UpdateChainPermissionWidget<ETHAddress, EthereumChain, IEthAddress,
        Web3EthereumChainAccount>(
      chain: chain,
      chains: chains,
      complete: complete,
      hasPermission: hasPermission,
      onChangeCurrentChain: onChangeCurrentChain,
      addAccount: addAccount,
      onChangeChain: onChangeChain,
      onChangeDefaultAccount: onChangeDefaultPermission,
      permissions: permissions[chain]!,
      defaultChainAddress: defaultChainAccount,
      activeChain: currentChain,
    );
  }
}
