import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/field.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/substrate/core/substrate.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';

class SubstrateRequestAccountForm extends SubstrateWeb3Form {
  final List<SubstrateChain> chains;
  late SubstrateChain _selectedNetwork = request.chain;
  SubstrateChain get chain => _selectedNetwork;
  final Web3SubstrateChain newPermission;

  void onChangeChain(SubstrateChain? chain) {
    _selectedNetwork = chain ?? _selectedNetwork;

    onChanged?.call();
  }

  void onChangeDefaultPermission(Web3SubstrateChainAccount? account) {
    if (account == null || account.defaultAddress) return;
    for (final e in chainPermission) {
      e.changeDefault(false);
    }
    account.changeDefault(true);
    onChanged?.call();
  }

  SubstrateRequestAccountForm._(
      {required this.request,
      required this.permissions,
      required this.newPermission,
      required List<SubstrateChain> chains})
      : chains = chains.imutable;
  factory SubstrateRequestAccountForm(
      {required Web3SubstrateRequest request,
      required List<SubstrateChain> chains}) {
    final Map<SubstrateChain,
        TransactionListFormField<Web3SubstrateChainAccount>> fields = {};
    for (final i in chains) {
      fields[i] = TransactionListFormField(
          name: "accounts",
          onChangeForm: (p0) => p0,
          values: request.currentPermission?.chainAccounts(i) ?? []);
    }
    return SubstrateRequestAccountForm._(
        request: request,
        chains: chains,
        permissions: fields,
        newPermission: Web3SubstrateChain.create(
            genesis: request.currentPermission?.currentChain));
  }
  @override
  OnChangeForm? onChanged;
  @override
  String get name => request.params.method.name;
  final Map<SubstrateChain, TransactionListFormField<Web3SubstrateChainAccount>>
      permissions;

  List<Web3SubstrateChainAccount> get chainPermission =>
      permissions[chain]!.value;

  Web3SubstrateChainAccount? accountPermission(ISubstrateAddress address) {
    return MethodUtils.nullOnException(() => permissions[chain]!
        .value
        .firstWhere((e) => e.address == address.networkAddress));
  }

  void addAccount(ISubstrateAddress address) {
    final exists = accountPermission(address);
    if (exists != null) {
      permissions[chain]?.removeValue(exists);
    } else {
      permissions[chain]?.addValue(Web3SubstrateChainAccount.fromChainAccount(
          address: address,
          genesis: chain.network.genesisBlock,
          isDefault: false));
    }
    if (permissions[chain]!.isNotEmpty &&
        !permissions[chain]!.value.any((e) => e.defaultAddress)) {
      permissions[chain]!.value[0].changeDefault(true);
    }
    onChanged?.call();
  }

  void complete() {
    assert(onCompleteForm != null, "Must not be null");
    final List<Web3SubstrateChainAccount> accounts = [];
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
  final Web3SubstrateRequest<dynamic, Web3SubstrateRequestParam> request;
}
