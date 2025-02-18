import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/chain/const.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/activity.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:on_chain/on_chain.dart';
import 'account.dart';

class Web3TronChain extends Web3Chain<TronAddress, TronChain,
    Web3TronChainAccount, WalletTronNetwork> {
  int _id;
  @override
  int get currentChain => _id;
  Web3TronChain._(
      {required super.accounts,
      required int currentChain,
      required super.activities})
      : _id = currentChain;
  @override
  Web3TronChain clone() {
    return Web3TronChain._(
        accounts: activeAccounts,
        currentChain: currentChain,
        activities: activities);
  }

  factory Web3TronChain.create({int? id}) {
    return Web3TronChain._(
        accounts: const [],
        currentChain: id ?? ChainConst.tronMainnetId,
        activities: const []);
  }

  @override
  List<Web3TronChainAccount> get activeAccounts => super.activeAccounts.cast();

  factory Web3TronChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, hex: hex, object: object, tags: NetworkType.tron.tag);
    return Web3TronChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3TronChainAccount.deserialize(object: e))
            .toList(),
        currentChain: values.elementAt(1),
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
  NetworkType get network => NetworkType.tron;

  @override
  ITronAddress getAccountPermission(
      {required TronAddress address, required TronChain chain}) {
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
  Web3TronChainAccount? getPermission(TronAddress address) {
    return activeAccounts.firstWhereOrNull((e) => e.address == address);
  }

  @override
  void setActiveChain(WalletTronNetwork network) {
    _id = network.value;
  }

  @override
  Web3TronChain disconnect() {
    return Web3TronChain._(
        accounts: const [],
        currentChain: ChainConst.tronMainnetId,
        activities: activities);
  }

  @override
  List<Web3TronChainAccount> chainAccounts(TronChain chain) {
    final currentAccounts =
        activeAccounts.where((e) => e.id == chain.network.value).toList();
    final List<Web3TronChainAccount> existsAccounts = [];
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
  Web3TronChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletTronNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final network = networks.firstWhere(
        (e) => e.network.value == currentNetwork.value,
        orElse: () => throw Web3RequestExceptionConst.invalidNetwork);
    final currentAccounts =
        activeAccounts.where((e) => e.id == currentNetwork.value).toList();
    return Web3TronChainAuthenticated(
        accounts: currentAccounts,
        network: network.network,
        serviceIdentifier: network.serviceIdentifier,
        chainIds: networks
            .map((e) =>
                BigInt.from(e.network.tronNetworkType.genesisBlockNumber))
            .toList());
  }

  @override
  TronChain getCurrentPermissionChain(List<TronChain> chain) {
    final currentNetwork =
        getCurrentPermissionNetwork(chain.map((e) => e.network).toList());
    List<Web3TronChainAccount> accounts = activeAccounts.clone();
    List<Web3TronChainAccount> existsAccount = [];
    for (final i in accounts) {
      final network = chain.firstWhereOrNull((e) => e.network.value == i.id);
      if (network == null) continue;
      final exist = network.addresses.any((e) => e.networkAddress == i.address);
      if (exist) existsAccount.add(i);
    }
    updateChainAccount(existsAccount);
    return chain.firstWhere(
      (e) => e.network == currentNetwork,
      orElse: () => throw Web3RequestExceptionConst.networkDoesNotExists,
    );
  }

  @override
  WalletTronNetwork getCurrentPermissionNetwork(
      List<WalletTronNetwork> networks) {
    final currentChain = _id;
    final network = networks.firstWhereOrNull((e) => e.value == currentChain);
    if (network != null) {
      return network;
    }
    final mainNetwork =
        networks.firstWhere((e) => e.value == ChainConst.tronMainnetId);
    List<Web3TronChainAccount> accounts =
        activeAccounts.clone().where((e) => e.id != currentChain).toList();
    setActiveChain(mainNetwork);
    updateChainAccount(accounts);
    return mainNetwork;
  }
}
