import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/field.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ethereum/forms/core/ethereum.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';

class EthereumRequestAccountForm extends EthereumWeb3Form {
  final List<EthereumChain> chains;
  late EthereumChain _selectedNetwork = request.chain;
  EthereumChain get chain => _selectedNetwork;
  final Web3EthereumChain newPermission;

  void onChangeChain(EthereumChain? chain) {
    _selectedNetwork = chain ?? _selectedNetwork;
    onChanged?.call();
  }

  EthereumRequestAccountForm._(
      {required this.request,
      required this.permissions,
      required this.newPermission,
      required List<EthereumChain> chains})
      : chains = chains.imutable;
  factory EthereumRequestAccountForm(
      {required Web3EthereumRequest request,
      required List<EthereumChain> chains}) {
    Map<EthereumChain, TransactionListFormField<Web3EthereumChainAccount>>
        fields = {};
    for (final i in chains) {
      fields[i] = TransactionListFormField(
          name: "accounts",
          onChangeForm: (p0) => p0,
          values: request.currentPermission?.chainAccounts(i) ?? []);
    }
    return EthereumRequestAccountForm._(
        request: request,
        chains: chains,
        permissions: fields,
        newPermission: Web3EthereumChain.create(
            chainId: request.currentPermission?.currentChain));
  }
  @override
  OnChangeForm? onChanged;
  @override
  String get name => request.params.method.name;

  final Map<EthereumChain, TransactionListFormField<Web3EthereumChainAccount>>
      permissions;

  List<Web3EthereumChainAccount> get chainPermission =>
      permissions[chain]!.value;

  Web3EthereumChainAccount? accountPermission(IEthAddress address) {
    return MethodUtils.nullOnException(() => permissions[chain]!
        .value
        .firstWhere(
            (e) => e.address.address == address.networkAddress.address));
  }

  bool hasPermission(IEthAddress address) {
    final contains = accountPermission(address) != null;
    return contains;
  }

  void onChangeDefaultPermission(Web3EthereumChainAccount? account) {
    if (account == null || account.defaultAddress) return;
    for (var e in chainPermission) {
      e.changeDefault(false);
    }
    account.changeDefault(true);
    onChanged?.call();
  }

  void addAccount(IEthAddress address) {
    final exists = accountPermission(address);
    if (exists != null) {
      permissions[chain]?.removeValue(exists);
    } else {
      permissions[chain]?.addValue(Web3EthereumChainAccount.fromChainAccount(
          address: address,
          chainId: chain.network.coinParam.chainId,
          defaultAddress: false));
    }
    if (permissions[chain]!.isNotEmpty &&
        !permissions[chain]!.value.any((e) => e.defaultAddress)) {
      permissions[chain]!.value[0].changeDefault(true);
    }

    onChanged?.call();
  }

  void complete() {
    assert(onCompeleteForm != null, "Must not be null");
    List<Web3EthereumChainAccount> accounts = [];
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
  final Web3EthereumRequest<dynamic, Web3EthereumRequestParam> request;
}
