import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/permission/permission.dart';
import 'package:on_chain/tron/src/address/tron_address.dart';

class TronWeb3PermissionView extends StatefulWidget {
  const TronWeb3PermissionView(
      {required this.permission,
      required this.onUpdateChainPermission,
      Key? key})
      : super(key: key);
  final Web3TronChain? permission;
  final OnUpdateChainPermission onUpdateChainPermission;

  @override
  State<TronWeb3PermissionView> createState() => _TronWeb3PermissionViewState();
}

class _TronWeb3PermissionViewState extends State<TronWeb3PermissionView>
    with SafeState {
  late TronChain currentChain;
  late Web3TronChain permission = widget.permission ?? Web3TronChain.create();

  late final List<TronChain> chains;
  Map<TronChain, List<Web3TronChainAccount>> permissions = {};
  late TronChain chain;

  Map<TronChain, Web3TronChainAccount> defaultAccount = {};

  List<Web3TronChainAccount> get chainPermission => permissions[chain]!;

  Web3TronChainAccount? get defaultChainAccount => defaultAccount[chain];

  Web3TronChainAccount? accountPermission(ITronAddress address) {
    return permissions[chain]!.firstWhereOrNull(
        (e) => e.address.toAddress() == address.networkAddress.toAddress());
  }

  void onChangeDefaultPermission(Web3TronChainAccount? account) {
    if (account == null) return;
    defaultAccount[chain] = account;
    updateState();
  }

  Web3TronChainAccount? hasPermission(ITronAddress address) {
    return accountPermission(address);
  }

  void addAccount(ITronAddress address) {
    final exists = accountPermission(address);
    if (exists != null) {
      permissions[chain]?.remove(exists);
    } else {
      permissions[chain]?.add(Web3TronChainAccount.fromChainAccount(
          address: address,
          chain: chain.network.tronNetworkType,
          isDefault: false));
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

  void onChangeCurrentChain(TronChain? chain) {
    if (chain == null) return;
    currentChain = chains.firstWhere(
        (e) => e.network.tronNetworkType == chain.network.tronNetworkType);
    updateState();
  }

  void onChangeChain(TronChain? updateChain) {
    chain = updateChain ?? chain;
    updateState();
  }

  void complete() {
    final newPermission =
        Web3TronChain.create(chain: currentChain.network.tronNetworkType);
    List<Web3TronChainAccount> accounts = [];
    for (final i in permissions.entries) {
      List<Web3TronChainAccount> chainAccounts = [];
      Web3TronChainAccount? defaultAddr = defaultAccount[i.key];
      defaultAddr ??= i.value.isEmpty ? null : i.value.first;
      for (final a in i.value) {
        Web3TronChainAccount account = a;
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
    chains = wallet.wallet.getChains().whereType<TronChain>().toList();
    currentChain = chains.firstWhere(
        (e) => e.network.tronNetworkType == permission.currentChain);
    for (final i in chains) {
      permissions[i] = permission.accounts
          .where((e) => e.chain == i.network.tronNetworkType)
          .toList();
    }
    chain = chains.firstWhere((e) =>
        e.network.tronNetworkType == currentChain.network.tronNetworkType);
    final Map<TronChain, Web3TronChainAccount> defaultAccount = {};
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
    return UpdateChainPermissionWidget<TronAddress, TronChain, ITronAddress,
        Web3TronChainAccount>(
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
