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

  void onChangeChain(EthereumChain? chain) {
    _selectedNetwork = chain ?? _selectedNetwork;
    onChanged?.call();
  }

  @override
  EthereumRequestAccountForm(
      {required this.request, required List<EthereumChain> chains})
      : chains = chains.imutable,
        permissions = _buildFields(
            chains: chains,
            currentPermissions: request.currentPermission?.accounts ?? []),
        newPermission = Web3EthereumChain.create(
            chainId: request.currentPermission?.currentChain);
  @override
  OnChangeForm? onChanged;
  @override
  String get name => request.params.method.name;
  static Map<EthereumChain, TransactionListFormField<Web3EthereumChainAccount>>
      _buildFields(
          {required List<Web3EthereumChainAccount> currentPermissions,
          required List<EthereumChain> chains}) {
    Map<EthereumChain, TransactionListFormField<Web3EthereumChainAccount>>
        fields = {};
    for (final i in chains) {
      fields[i] = TransactionListFormField(
          name: "accounts",
          onChangeForm: (p0) => p0,
          values: currentPermissions
              .where((e) => e.chainId == i.network.coinParam.chainId)
              .toList());
    }
    return fields;
  }

  final Map<EthereumChain, TransactionListFormField<Web3EthereumChainAccount>>
      permissions;

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

  void addAccount(IEthAddress address) {
    final exists = accountPermission(address);
    if (exists != null) {
      permissions[chain]?.removeValue(exists);
    } else {
      permissions[chain]?.addValue(Web3EthereumChainAccount.fromChainAccount(
          address: address, chainId: chain.network.coinParam.chainId));
    }
    onChanged?.call();
  }

  void complete() {
    assert(onCompeleteForm != null, "Must not be null");
    final accounts =
        permissions.values.map((e) => e.value).expand((e) => e).toList();
    newPermission.updateChainAccount(accounts);
    onCompeleteForm?.call(newPermission);
  }

  @override
  final Web3EthereumRequest<dynamic, Web3EthereumRequestParam> request;
}
