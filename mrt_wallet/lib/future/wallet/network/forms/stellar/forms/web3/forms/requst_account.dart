import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/field.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/stellar/forms/core/stellar.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';

class StellarRequestAccountForm extends StellarWeb3Form {
  final List<StellarChain> chains;
  late StellarChain _selectedNetwork = request.chain;
  StellarChain get chain => _selectedNetwork;
  final Web3StellarChain newPermission;

  void onChangeChain(StellarChain? chain) {
    _selectedNetwork = chain ?? _selectedNetwork;

    onChanged?.call();
  }

  void onChangeDefaultPermission(Web3StellarChainAccount? account) {
    if (account == null || account.defaultAddress) return;
    for (var e in chainPermission) {
      e.changeDefault(false);
    }
    account.changeDefault(true);
    onChanged?.call();
  }

  StellarRequestAccountForm._(
      {required this.request,
      required this.permissions,
      required this.newPermission,
      required List<StellarChain> chains})
      : chains = chains.imutable;
  factory StellarRequestAccountForm(
      {required Web3StellarRequest request,
      required List<StellarChain> chains}) {
    Map<StellarChain, TransactionListFormField<Web3StellarChainAccount>>
        fields = {};
    for (final i in chains) {
      fields[i] = TransactionListFormField(
          name: "accounts",
          onChangeForm: (p0) => p0,
          values: request.currentPermission?.chainAccounts(i) ?? []);
    }
    return StellarRequestAccountForm._(
        request: request,
        chains: chains,
        permissions: fields,
        newPermission: Web3StellarChain.create(
            passphrase: request.currentPermission?.currentChain));
  }
  @override
  OnChangeForm? onChanged;
  @override
  String get name => request.params.method.name;
  final Map<StellarChain, TransactionListFormField<Web3StellarChainAccount>>
      permissions;

  List<Web3StellarChainAccount> get chainPermission =>
      permissions[chain]!.value;

  Web3StellarChainAccount? accountPermission(IStellarAddress address) {
    return MethodUtils.nullOnException(() => permissions[chain]!
        .value
        .firstWhere((e) => e.address == address.networkAddress));
  }

  void addAccount(IStellarAddress address) {
    final exists = accountPermission(address);
    if (exists != null) {
      permissions[chain]?.removeValue(exists);
    } else {
      permissions[chain]?.addValue(Web3StellarChainAccount.fromChainAccount(
          address: address,
          passphrase: chain.network.coinParam.passphrase,
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
    List<Web3StellarChainAccount> accounts = [];
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
  final Web3StellarRequest<dynamic, Web3StellarRequestParam> request;
}
