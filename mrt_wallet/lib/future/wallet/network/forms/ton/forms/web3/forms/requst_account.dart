import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/field.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ton/forms/core/ton.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';

class TonRequestAccountForm extends TonWeb3Form {
  final List<TheOpenNetworkChain> chains;
  late TheOpenNetworkChain _selectedNetwork = request.chain;
  TheOpenNetworkChain get chain => _selectedNetwork;
  final Web3TonChain newPermission;

  void onChangeChain(TheOpenNetworkChain? chain) {
    _selectedNetwork = chain ?? _selectedNetwork;

    onChanged?.call();
  }

  void onChangeDefaultPermission(Web3TonChainAccount? account) {
    if (account == null || account.defaultAddress) return;
    for (var e in chainPermission) {
      e.changeDefault(false);
    }
    account.changeDefault(true);
    onChanged?.call();
  }

  TonRequestAccountForm._(
      {required this.request,
      required this.permissions,
      required this.newPermission,
      required List<TheOpenNetworkChain> chains})
      : chains = chains.imutable;
  factory TonRequestAccountForm(
      {required Web3TonRequest request,
      required List<TheOpenNetworkChain> chains}) {
    Map<TheOpenNetworkChain, TransactionListFormField<Web3TonChainAccount>>
        fields = {};
    for (final i in chains) {
      fields[i] = TransactionListFormField(
          name: "accounts",
          onChangeForm: (p0) => p0,
          values: request.currentPermission?.chainAccounts(i) ?? []);
    }
    return TonRequestAccountForm._(
        request: request,
        chains: chains,
        permissions: fields,
        newPermission: Web3TonChain.create(
            workChain: request.currentPermission?.currentChain));
  }
  @override
  OnChangeForm? onChanged;
  @override
  String get name => request.params.method.name;
  final Map<TheOpenNetworkChain, TransactionListFormField<Web3TonChainAccount>>
      permissions;

  List<Web3TonChainAccount> get chainPermission => permissions[chain]!.value;

  Web3TonChainAccount? accountPermission(ITonAddress address) {
    return MethodUtils.nullOnException(() => permissions[chain]!
        .value
        .firstWhere((e) => e.address == address.networkAddress));
  }

  void addAccount(ITonAddress address) {
    final exists = accountPermission(address);
    if (exists != null) {
      permissions[chain]?.removeValue(exists);
    } else {
      permissions[chain]?.addValue(Web3TonChainAccount.fromChainAccount(
          address: address,
          workChain: chain.network.coinParam.workchain,
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
    List<Web3TonChainAccount> accounts = [];
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
  final Web3TonRequest<dynamic, Web3TonRequestParam> request;
}
