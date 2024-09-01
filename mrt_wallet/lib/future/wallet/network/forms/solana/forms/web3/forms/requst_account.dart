import 'package:mrt_wallet/app/utils/list/extention.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/field.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/solana/forms/core/solana.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/solana.dart';

class SolanaRequestAccountForm extends SolanaWeb3Form {
  final List<SolanaChain> chains;
  late SolanaChain _selectedNetwork = request.chain;
  SolanaChain get chain => _selectedNetwork;
  final Web3SolanaChain newPermission;

  late SolanaChain _activeChain = chains
      .firstWhere((e) => e.network.genesisBlock == newPermission.currentChain);

  SolanaChain get activeChain => _activeChain;

  void onChangeActiveChain(SolanaChain? chain) {
    _activeChain = chain ?? _activeChain;
    onChanged?.call();
  }

  void onChangeChain(SolanaChain? chain) {
    _selectedNetwork = chain ?? _selectedNetwork;

    onChanged?.call();
  }

  void onChangeDefaultPermission(Web3SolanaChainAccount? account) {
    if (account == null) return;
    _defaultAccount[chain] = account;
    onChanged?.call();
  }

  SolanaRequestAccountForm._(
      {required this.request,
      required this.permissions,
      required Map<SolanaChain, Web3SolanaChainAccount> defaultAccount,
      required this.newPermission,
      required List<SolanaChain> chains})
      : chains = chains.imutable,
        _defaultAccount = defaultAccount;
  factory SolanaRequestAccountForm(
      {required Web3SolanaRequest request, required List<SolanaChain> chains}) {
    final List<Web3SolanaChainAccount> currentPermissions =
        request.currentPermission?.accounts ?? [];
    Map<SolanaChain, TransactionListFormField<Web3SolanaChainAccount>> fields =
        {};
    for (final i in chains) {
      fields[i] = TransactionListFormField(
          name: "accounts",
          onChangeForm: (p0) => p0,
          values: currentPermissions
              .where((e) => e.genesis == i.network.genesisBlock)
              .toList());
    }
    final Map<SolanaChain, Web3SolanaChainAccount> defaultAccount = {};
    for (final i in chains) {
      final accounts = fields[i]!.value;
      final defaultAddress = accounts.firstWhereOrNull((e) => e.defaultAddress);
      if (defaultAddress != null) {
        defaultAccount[i] = defaultAddress;
      }
    }
    return SolanaRequestAccountForm._(
        request: request,
        chains: chains,
        defaultAccount: defaultAccount,
        permissions: fields,
        newPermission: Web3SolanaChain.create(
            genesisBlock: request.currentPermission?.currentChain));
  }
  @override
  OnChangeForm? onChanged;
  @override
  String get name => request.params.method.name;
  final Map<SolanaChain, TransactionListFormField<Web3SolanaChainAccount>>
      permissions;

  final Map<SolanaChain, Web3SolanaChainAccount> _defaultAccount;

  List<Web3SolanaChainAccount> get chainPermission => permissions[chain]!.value;

  Web3SolanaChainAccount? get defaultChainAccount => _defaultAccount[chain];

  Web3SolanaChainAccount? accountPermission(ISolanaAddress address) {
    return MethodUtils.nullOnException(() => permissions[chain]!
        .value
        .firstWhere(
            (e) => e.address.address == address.networkAddress.address));
  }

  void addAccount(ISolanaAddress address) {
    final exists = accountPermission(address);
    if (exists != null) {
      permissions[chain]?.removeValue(exists);
    } else {
      permissions[chain]?.addValue(Web3SolanaChainAccount.fromChainAccount(
          address: address,
          genesis: chain.network.genesisBlock,
          isDefault: false));
    }
    if (permissions[chain]!.value.isEmpty) {
      _defaultAccount.remove(chain);
    } else {
      if (!permissions[chain]!.value.contains(defaultChainAccount)) {
        _defaultAccount[chain] = permissions[chain]!.value[0];
      }
    }
    onChanged?.call();
  }

  void complete() {
    assert(onCompeleteForm != null, "Must not be null");
    List<Web3SolanaChainAccount> accounts = [];
    for (final i in permissions.entries) {
      Web3SolanaChainAccount? defaultAddr = _defaultAccount[i.key];
      defaultAddr ??= i.value.value.isEmpty ? null : i.value.value.first;
      for (final a in i.value.value) {
        Web3SolanaChainAccount account = a;
        if (account == defaultAddr && !account.defaultAddress) {
          account = account.changeDefault(true);
        } else if (account.defaultAddress) {
          account = account.changeDefault(false);
        }
        accounts.add(account);
      }
    }
    newPermission.updateChainAccount(accounts);
    newPermission.setActiveChain(_activeChain);
    onCompeleteForm?.call(newPermission);
  }

  @override
  final Web3SolanaRequest<dynamic, Web3SolanaRequestParam> request;
}
