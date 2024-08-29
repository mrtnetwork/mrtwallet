import 'package:mrt_wallet/app/utils/list/extention.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/field.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/core/tron.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class TronRequestAccountForm extends TronWeb3Form {
  final List<TronChain> chains;
  late TronChain _selectedNetwork = request.chain;
  TronChain get chain => _selectedNetwork;
  final Web3TronChain newPermission;

  late TronChain _activeChain = chains.firstWhere(
      (e) => e.network.tronNetworkType == newPermission.currentChain);

  TronChain get activeChain => _activeChain;

  void onChangeActiveChain(TronChain? chain) {
    _activeChain = chain ?? _activeChain;
    onChanged?.call();
  }

  void onChangeChain(TronChain? chain) {
    _selectedNetwork = chain ?? _selectedNetwork;

    onChanged?.call();
  }

  void onChangeDefaultPermission(Web3TronChainAccount? account) {
    if (account == null) return;
    _defaultAccount[chain] = account;
    onChanged?.call();
  }

  TronRequestAccountForm._(
      {required this.request,
      required this.permissions,
      required Map<TronChain, Web3TronChainAccount> defaultAccount,
      required this.newPermission,
      required List<TronChain> chains})
      : chains = chains.imutable,
        _defaultAccount = defaultAccount;
  factory TronRequestAccountForm(
      {required Web3TronRequest request, required List<TronChain> chains}) {
    final List<Web3TronChainAccount> currentPermissions =
        request.currentPermission?.accounts ?? [];
    Map<TronChain, TransactionListFormField<Web3TronChainAccount>> fields = {};
    for (final i in chains) {
      fields[i] = TransactionListFormField(
          name: "accounts",
          onChangeForm: (p0) => p0,
          values: currentPermissions
              .where((e) => e.chain == i.network.tronNetworkType)
              .toList());
    }
    final Map<TronChain, Web3TronChainAccount> defaultAccount = {};
    for (final i in chains) {
      final accounts = fields[i]!.value;
      final defaultAddress = accounts.firstWhereOrNull((e) => e.defaultAddress);
      if (defaultAddress != null) {
        defaultAccount[i] = defaultAddress;
      }
    }
    return TronRequestAccountForm._(
        request: request,
        chains: chains,
        defaultAccount: defaultAccount,
        permissions: fields,
        newPermission: Web3TronChain.create(
            chain: request.currentPermission?.currentChain));
  }
  @override
  OnChangeForm? onChanged;
  @override
  String get name => request.params.method.name;
  final Map<TronChain, TransactionListFormField<Web3TronChainAccount>>
      permissions;

  final Map<TronChain, Web3TronChainAccount> _defaultAccount;

  List<Web3TronChainAccount> get chainPermission => permissions[chain]!.value;

  Web3TronChainAccount? get defaultChainAccount => _defaultAccount[chain];

  Web3TronChainAccount? accountPermission(ITronAddress address) {
    return MethodUtils.nullOnException(() => permissions[chain]!
        .value
        .firstWhere((e) =>
            e.address.toAddress() == address.networkAddress.toAddress()));
  }

  void addAccount(ITronAddress address) {
    final exists = accountPermission(address);
    if (exists != null) {
      permissions[chain]?.removeValue(exists);
    } else {
      permissions[chain]?.addValue(Web3TronChainAccount.fromChainAccount(
          address: address,
          chain: chain.network.tronNetworkType,
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
    List<Web3TronChainAccount> accounts = [];
    for (final i in permissions.entries) {
      Web3TronChainAccount? defaultAddr = _defaultAccount[i.key];
      defaultAddr ??= i.value.value.isEmpty ? null : i.value.value.first;
      for (final a in i.value.value) {
        Web3TronChainAccount account = a;
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
  final Web3TronRequest<dynamic, Web3TronRequestParam> request;
}
