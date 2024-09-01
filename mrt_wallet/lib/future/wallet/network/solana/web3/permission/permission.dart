import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/web3.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/solana.dart';
import 'package:on_chain/solana/solana.dart';

class SolanaWeb3PermissionView extends StatefulWidget {
  const SolanaWeb3PermissionView(
      {required this.permission,
      required this.onUpdateChainPermission,
      Key? key})
      : super(key: key);
  final Web3SolanaChain? permission;
  final OnUpdateChainPermission onUpdateChainPermission;

  @override
  State<SolanaWeb3PermissionView> createState() =>
      _TronWeb3PermissionViewState();
}

class _TronWeb3PermissionViewState extends State<SolanaWeb3PermissionView>
    with SafeState {
  late SolanaChain currentChain;
  late Web3SolanaChain permission =
      widget.permission ?? Web3SolanaChain.create();

  late final List<SolanaChain> chains;
  Map<SolanaChain, List<Web3SolanaChainAccount>> permissions = {};
  late SolanaChain chain;

  Map<SolanaChain, Web3SolanaChainAccount> defaultAccount = {};

  List<Web3SolanaChainAccount> get chainPermission => permissions[chain]!;

  Web3SolanaChainAccount? get defaultChainAccount => defaultAccount[chain];

  Web3SolanaChainAccount? accountPermission(ISolanaAddress address) {
    return permissions[chain]!.firstWhereOrNull(
        (e) => e.address.address == address.networkAddress.address);
  }

  void onChangeDefaultPermission(Web3SolanaChainAccount? account) {
    if (account == null) return;
    defaultAccount[chain] = account;
    updateState();
  }

  Web3SolanaChainAccount? hasPermission(ISolanaAddress address) {
    return accountPermission(address);
  }

  void addAccount(ISolanaAddress address) {
    final exists = accountPermission(address);
    if (exists != null) {
      permissions[chain]?.remove(exists);
    } else {
      permissions[chain]?.add(Web3SolanaChainAccount.fromChainAccount(
          address: address,
          genesis: chain.network.genesisBlock,
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

  void onChangeCurrentChain(SolanaChain? chain) {
    if (chain == null) return;
    currentChain = chains.firstWhere(
        (e) => e.network.genesisBlock == chain.network.genesisBlock);
    updateState();
  }

  void onChangeChain(SolanaChain? updateChain) {
    chain = updateChain ?? chain;
    updateState();
  }

  void complete() {
    final newPermission =
        Web3SolanaChain.create(genesisBlock: currentChain.network.genesisBlock);
    List<Web3SolanaChainAccount> accounts = [];
    for (final i in permissions.entries) {
      List<Web3SolanaChainAccount> chainAccounts = [];
      Web3SolanaChainAccount? defaultAddr = defaultAccount[i.key];
      defaultAddr ??= i.value.isEmpty ? null : i.value.first;
      for (final a in i.value) {
        Web3SolanaChainAccount account = a;
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
    chains = wallet.wallet.getChains().whereType<SolanaChain>().toList();
    currentChain = chains
        .firstWhere((e) => e.network.genesisBlock == permission.currentChain);
    for (final i in chains) {
      permissions[i] = permission.accounts
          .where((e) => e.genesis == i.network.genesisBlock)
          .toList();
    }
    chain = chains.firstWhere(
        (e) => e.network.genesisBlock == currentChain.network.genesisBlock);
    final Map<SolanaChain, Web3SolanaChainAccount> defaultAccount = {};
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
    return UpdateChainPermissionWidget<SolAddress, SolanaChain, ISolanaAddress,
        Web3SolanaChainAccount>(
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
