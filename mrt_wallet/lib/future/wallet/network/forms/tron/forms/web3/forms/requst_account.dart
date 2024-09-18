import 'package:mrt_wallet/app/utils/list/extension.dart';
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

  void onChangeChain(TronChain? chain) {
    _selectedNetwork = chain ?? _selectedNetwork;

    onChanged?.call();
  }

  void onChangeDefaultPermission(Web3TronChainAccount? account) {
    if (account == null || account.defaultAddress) return;
    for (var e in chainPermission) {
      e.changeDefault(false);
    }
    account.changeDefault(true);
    onChanged?.call();
  }

  TronRequestAccountForm._(
      {required this.request,
      required this.permissions,
      required this.newPermission,
      required List<TronChain> chains})
      : chains = chains.imutable;
  factory TronRequestAccountForm(
      {required Web3TronRequest request, required List<TronChain> chains}) {
    Map<TronChain, TransactionListFormField<Web3TronChainAccount>> fields = {};
    for (final i in chains) {
      fields[i] = TransactionListFormField(
          name: "accounts",
          onChangeForm: (p0) => p0,
          values: request.currentPermission?.chainAccounts(i) ?? []);
    }
    return TronRequestAccountForm._(
        request: request,
        chains: chains,
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

  List<Web3TronChainAccount> get chainPermission => permissions[chain]!.value;

  Web3TronChainAccount? accountPermission(ITronAddress address) {
    return permissions[chain]!.value.firstWhereOrNull((e) =>
        e.address == address.networkAddress && e.keyIndex == address.keyIndex);
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
    if (permissions[chain]!.isNotEmpty &&
        !permissions[chain]!.value.any((e) => e.defaultAddress)) {
      permissions[chain]!.value[0].changeDefault(true);
    }
    onChanged?.call();
  }

  void complete() {
    assert(onCompeleteForm != null, "Must not be null");
    List<Web3TronChainAccount> accounts = [];
    for (final i in permissions.entries) {
      if (i.value.isEmpty) continue;
      final defaultAddresses = i.value.value.where((e) => e.defaultAddress);
      if (defaultAddresses.isEmpty) {
        i.value.value.first.changeDefault(true);
      } else if (defaultAddresses.length > 1) {
        for (var e in i.value.value) {
          e.changeDefault(false);
        }
        i.value.value.first.changeDefault(true);
      }
      accounts.addAll(i.value.value);
    }
    newPermission.updateChainAccount(accounts);
    newPermission.setActiveChain(chain);
    onCompeleteForm?.call(newPermission);
  }

  @override
  final Web3TronRequest<dynamic, Web3TronRequestParam> request;
}
