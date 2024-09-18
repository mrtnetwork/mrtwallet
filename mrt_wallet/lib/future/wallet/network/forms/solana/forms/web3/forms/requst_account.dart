import 'package:mrt_wallet/app/utils/list/extension.dart';
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

  void onChangeChain(SolanaChain? chain) {
    _selectedNetwork = chain ?? _selectedNetwork;
    onChanged?.call();
  }

  void onChangeDefaultPermission(Web3SolanaChainAccount? account) {
    if (account == null || account.defaultAddress) return;
    for (var e in chainPermission) {
      e.changeDefault(false);
    }
    account.changeDefault(true);
    onChanged?.call();
  }

  SolanaRequestAccountForm._(
      {required this.request,
      required this.permissions,
      required this.newPermission,
      required List<SolanaChain> chains})
      : chains = chains.imutable;
  factory SolanaRequestAccountForm(
      {required Web3SolanaRequest request, required List<SolanaChain> chains}) {
    Map<SolanaChain, TransactionListFormField<Web3SolanaChainAccount>> fields =
        {};
    for (final i in chains) {
      fields[i] = TransactionListFormField(
          name: "accounts",
          onChangeForm: (p0) => p0,
          values: request.currentPermission?.chainAccounts(i) ?? []);
    }
    return SolanaRequestAccountForm._(
        request: request,
        chains: chains,
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

  List<Web3SolanaChainAccount> get chainPermission => permissions[chain]!.value;

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
    if (permissions[chain]!.isNotEmpty &&
        !permissions[chain]!.value.any((e) => e.defaultAddress)) {
      permissions[chain]!.value[0].changeDefault(true);
    }
    onChanged?.call();
  }

  void complete() {
    assert(onCompeleteForm != null, "Must not be null");
    List<Web3SolanaChainAccount> accounts = [];
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
  final Web3SolanaRequest<dynamic, Web3SolanaRequestParam> request;
}
