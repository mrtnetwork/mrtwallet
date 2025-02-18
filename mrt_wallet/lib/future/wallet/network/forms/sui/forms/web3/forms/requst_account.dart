import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/field.dart';
import 'package:mrt_wallet/future/wallet/network/forms/sui/forms/core/sui.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/sui.dart';

class SuiRequestAccountForm extends SuiWeb3Form {
  final List<SuiChain> chains;
  late SuiChain _selectedNetwork = request.chain;
  SuiChain get chain => _selectedNetwork;
  final Web3SuiChain newPermission;

  void onChangeChain(SuiChain? chain) {
    _selectedNetwork = chain ?? _selectedNetwork;
    onChanged?.call();
  }

  void onChangeDefaultPermission(Web3SuiChainAccount? account) {
    if (account == null || account.defaultAddress) return;
    for (final e in chainPermission) {
      e.changeDefault(false);
    }
    account.changeDefault(true);
    onChanged?.call();
  }

  SuiRequestAccountForm._(
      {required this.request,
      required this.permissions,
      required this.newPermission,
      required List<SuiChain> chains})
      : chains = chains.imutable;
  factory SuiRequestAccountForm(
      {required Web3SuiRequest request, required List<SuiChain> chains}) {
    final Map<SuiChain, TransactionListFormField<Web3SuiChainAccount>> fields =
        {};
    for (final i in chains) {
      fields[i] = TransactionListFormField(
          name: "accounts",
          onChangeForm: (p0) => p0,
          values: request.currentPermission?.chainAccounts(i) ?? []);
    }
    return SuiRequestAccountForm._(
        request: request,
        chains: chains,
        permissions: fields,
        newPermission:
            Web3SuiChain.create(id: request.currentPermission?.currentChain));
  }
  @override
  String get name => request.params.method.name;
  final Map<SuiChain, TransactionListFormField<Web3SuiChainAccount>>
      permissions;

  List<Web3SuiChainAccount> get chainPermission => permissions[chain]!.value;

  Web3SuiChainAccount? accountPermission(ISuiAddress address) {
    return MethodUtils.nullOnException(() => permissions[chain]!
        .value
        .firstWhere(
            (e) => e.address.address == address.networkAddress.address));
  }

  void addAccount(ISuiAddress address) {
    final exists = accountPermission(address);
    if (exists != null) {
      permissions[chain]?.removeValue(exists);
    } else {
      permissions[chain]?.addValue(Web3SuiChainAccount.fromChainAccount(
          address: address, id: chain.network.value, isDefault: false));
    }
    if (permissions[chain]!.isNotEmpty &&
        !permissions[chain]!.value.any((e) => e.defaultAddress)) {
      permissions[chain]!.value[0].changeDefault(true);
    }
    onChanged?.call();
  }

  void complete() {
    assert(onCompleteForm != null, "Must not be null");
    final List<Web3SuiChainAccount> accounts = [];
    for (final i in permissions.entries) {
      if (i.value.isEmpty) continue;
      final defaultAddresses = i.value.value.where((e) => e.defaultAddress);
      if (defaultAddresses.isEmpty) {
        i.value.value.first.changeDefault(true);
      } else if (defaultAddresses.length > 1) {
        for (final e in i.value.value) {
          e.changeDefault(false);
        }
        i.value.value.first.changeDefault(true);
      }
      accounts.addAll(i.value.value);
    }
    newPermission.updateChainAccount(accounts);
    newPermission.setActiveChain(chain.network);
    onCompleteForm?.call(newPermission);
  }

  @override
  final Web3SuiRequest<dynamic, Web3SuiRequestParam> request;
}
