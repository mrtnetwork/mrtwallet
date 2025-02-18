import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/field.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/future/wallet/network/forms/aptos/forms/core/aptos.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/aptos.dart';

class AptosRequestAccountForm extends AptosWeb3Form {
  final List<AptosChain> chains;
  late AptosChain _selectedNetwork = request.chain;
  AptosChain get chain => _selectedNetwork;
  final Web3AptosChain newPermission;

  void onChangeChain(AptosChain? chain) {
    _selectedNetwork = chain ?? _selectedNetwork;
    onChanged?.call();
  }

  void onChangeDefaultPermission(Web3AptosChainAccount? account) {
    if (account == null || account.defaultAddress) return;
    for (final e in chainPermission) {
      e.changeDefault(false);
    }
    account.changeDefault(true);
    onChanged?.call();
  }

  AptosRequestAccountForm._(
      {required this.request,
      required this.permissions,
      required this.newPermission,
      required List<AptosChain> chains})
      : chains = chains.imutable;
  factory AptosRequestAccountForm(
      {required Web3AptosRequest request, required List<AptosChain> chains}) {
    final Map<AptosChain, TransactionListFormField<Web3AptosChainAccount>>
        fields = {};
    for (final i in chains) {
      fields[i] = TransactionListFormField(
          name: "accounts",
          onChangeForm: (p0) => p0,
          values: request.currentPermission?.chainAccounts(i) ?? []);
    }
    return AptosRequestAccountForm._(
        request: request,
        chains: chains,
        permissions: fields,
        newPermission:
            Web3AptosChain.create(id: request.currentPermission?.currentChain));
  }
  @override
  String get name => request.params.method.name;
  final Map<AptosChain, TransactionListFormField<Web3AptosChainAccount>>
      permissions;

  List<Web3AptosChainAccount> get chainPermission => permissions[chain]!.value;

  Web3AptosChainAccount? accountPermission(IAptosAddress address) {
    return MethodUtils.nullOnException(() => permissions[chain]!
        .value
        .firstWhere(
            (e) => e.address.address == address.networkAddress.address));
  }

  void addAccount(IAptosAddress address) {
    final exists = accountPermission(address);
    if (exists != null) {
      permissions[chain]?.removeValue(exists);
    } else {
      permissions[chain]?.addValue(Web3AptosChainAccount.fromChainAccount(
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
    final List<Web3AptosChainAccount> accounts = [];
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
  final Web3AptosRequest<dynamic, Web3AptosRequestParam> request;
}
