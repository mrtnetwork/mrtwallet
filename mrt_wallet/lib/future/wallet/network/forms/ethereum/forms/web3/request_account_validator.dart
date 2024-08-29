import 'package:mrt_wallet/app/utils/list/extention.dart';
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
  late EthereumChain _activeChain =
      chains.firstWhere((e) => e.chainId == newPermission.currentChain);

  EthereumChain get activeChain => _activeChain;

  void onChangeActiveChain(EthereumChain? chain) {
    _activeChain = chain ?? _activeChain;
    onChanged?.call();
  }

  void onChangeChain(EthereumChain? chain) {
    _selectedNetwork = chain ?? _selectedNetwork;
    onChanged?.call();
  }

  EthereumRequestAccountForm._(
      {required this.request,
      required this.permissions,
      required Map<EthereumChain, Web3EthereumChainAccount> defaultAccount,
      required this.newPermission,
      required List<EthereumChain> chains})
      : chains = chains.imutable,
        _defaultAccount = defaultAccount;
  factory EthereumRequestAccountForm(
      {required Web3EthereumRequest request,
      required List<EthereumChain> chains}) {
    final List<Web3EthereumChainAccount> currentPermissions =
        request.currentPermission?.accounts ?? [];
    Map<EthereumChain, TransactionListFormField<Web3EthereumChainAccount>>
        fields = {};
    for (final i in chains) {
      fields[i] = TransactionListFormField(
          name: "accounts",
          onChangeForm: (p0) => p0,
          values:
              currentPermissions.where((e) => e.chainId == i.chainId).toList());
    }
    final Map<EthereumChain, Web3EthereumChainAccount> defaultAccount = {};
    for (final i in chains) {
      final accounts = fields[i]!.value;
      final defaultAddress = accounts.firstWhereOrNull((e) => e.defaultAddress);
      if (defaultAddress != null) {
        defaultAccount[i] = defaultAddress;
      }
    }
    return EthereumRequestAccountForm._(
        request: request,
        chains: chains,
        defaultAccount: defaultAccount,
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

  final Map<EthereumChain, Web3EthereumChainAccount> _defaultAccount;

  List<Web3EthereumChainAccount> get chainPermission =>
      permissions[chain]!.value;

  Web3EthereumChainAccount? get defaultChainAccount => _defaultAccount[chain];

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
    if (account == null) return;
    _defaultAccount[chain] = account;
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
    List<Web3EthereumChainAccount> accounts = [];
    for (final i in permissions.entries) {
      Web3EthereumChainAccount? defaultAddr = _defaultAccount[i.key];
      defaultAddr ??= i.value.value.isEmpty ? null : i.value.value.first;
      for (final a in i.value.value) {
        Web3EthereumChainAccount account = a;
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
  final Web3EthereumRequest<dynamic, Web3EthereumRequestParam> request;
}
