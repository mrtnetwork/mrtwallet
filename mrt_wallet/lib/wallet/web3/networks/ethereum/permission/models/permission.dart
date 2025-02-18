import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/activity.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:on_chain/on_chain.dart';
import 'account.dart';

class Web3EthereumChain extends Web3Chain<ETHAddress, EthereumChain,
    Web3EthereumChainAccount, WalletEthereumNetwork> {
  int _id;
  @override
  int get currentChain => _id;
  Web3EthereumChain._(
      {required super.accounts, required int id, required super.activities})
      : _id = id;
  @override
  Web3EthereumChain clone() {
    return Web3EthereumChain._(
        accounts: activeAccounts, id: currentChain, activities: activities);
  }

  factory Web3EthereumChain.create({int? id}) {
    return Web3EthereumChain._(
        accounts: const [],
        id: id ?? ChainConst.ethereumMainnetId,
        activities: const []);
  }

  @override
  List<Web3EthereumChainAccount> get activeAccounts =>
      super.activeAccounts.cast();

  factory Web3EthereumChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: NetworkType.ethereum.tag);
    return Web3EthereumChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3EthereumChainAccount.deserialize(object: e))
            .toList(),
        id: values.elementAt(1),
        activities: values
            .elementAt<List<dynamic>>(2)
            .map((e) => Web3AccountAcitvity.deserialize(object: e))
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(
              activeAccounts.map((e) => e.toCbor()).toList()),
          _id,
          CborListValue.fixedLength(activities.map((e) => e.toCbor()).toList()),
        ]),
        network.tag);
  }

  @override
  NetworkType get network => NetworkType.ethereum;

  @override
  IEthAddress getAccountPermission(
      {required ETHAddress address, required EthereumChain chain}) {
    try {
      final permissionAccount = activeAccounts.firstWhere(
          (e) => e.address == address && e.id == chain.network.value);
      final chainAccount = chain.addresses.firstWhere((e) {
        return e.networkAddress == permissionAccount.address &&
            e.keyIndex == permissionAccount.keyIndex;
      });
      return chainAccount;
    } on StateError {
      throw Web3RequestExceptionConst.missingPermission;
    }
  }

  @override
  Web3EthereumChainAccount? getPermission(ETHAddress address) {
    return activeAccounts.firstWhereOrNull((e) => e.address == address);
  }

  @override
  void setActiveChain(WalletEthereumNetwork network) {
    _id = network.value;
  }

  @override
  Web3EthereumChain disconnect() {
    return Web3EthereumChain._(
        accounts: const [],
        id: ChainConst.ethereumMainnetId,
        activities: activities);
  }

  @override
  List<Web3EthereumChainAccount> chainAccounts(EthereumChain chain) {
    final currentAccounts =
        activeAccounts.where((e) => e.id == chain.network.value).toList();
    final List<Web3EthereumChainAccount> existsAccounts = [];
    for (final i in chain.addresses) {
      final chainAccount = currentAccounts.firstWhereOrNull(
          (e) => e.addressStr == i.address.address && e.keyIndex == i.keyIndex);
      if (chainAccount != null) {
        existsAccounts.add(chainAccount);
      }
    }
    return existsAccounts;
  }

  @override
  Web3EthereumChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletEthereumNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final network = networks.firstWhere(
        (e) => e.network.coinParam.chainId == currentNetwork.coinParam.chainId,
        orElse: () => throw Web3RequestExceptionConst.invalidNetwork);
    final currentAccounts =
        activeAccounts.where((e) => e.id == currentNetwork.value).toList();
    return Web3EthereumChainAuthenticated(
        accounts: currentAccounts,
        network: network.network,
        serviceIdentifier: network.serviceIdentifier,
        existsChain: networks.map((e) => e.network.coinParam.chainId).toList());
  }

  @override
  EthereumChain getCurrentPermissionChain(List<EthereumChain> chain) {
    final currentNetwork =
        getCurrentPermissionNetwork(chain.map((e) => e.network).toList());
    List<Web3EthereumChainAccount> accounts = activeAccounts.clone();
    List<Web3EthereumChainAccount> existsAccount = [];
    for (final i in accounts) {
      final network = chain.firstWhereOrNull((e) => e.network.value == i.id);
      if (network == null) continue;
      final exist = network.addresses.any((e) => e.networkAddress == i.address);
      if (exist) existsAccount.add(i);
    }
    updateChainAccount(existsAccount);
    return chain.firstWhere(
      (e) => e.network == currentNetwork,
      orElse: () => throw Web3RequestExceptionConst.ethereumNetworkDoesNotExist,
    );
  }

  @override
  WalletEthereumNetwork getCurrentPermissionNetwork(
      List<WalletEthereumNetwork> networks) {
    final currentChain = _id;
    final network = networks.firstWhereOrNull((e) => e.value == currentChain);
    if (network != null) {
      return network;
    }
    final mainNetwork =
        networks.firstWhere((e) => e.coinParam.chainId == BigInt.one);
    List<Web3EthereumChainAccount> accounts =
        activeAccounts.clone().where((e) => e.id != currentChain).toList();
    setActiveChain(mainNetwork);
    updateChainAccount(accounts);
    return mainNetwork;
  }
}
