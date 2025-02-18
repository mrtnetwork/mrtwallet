import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/activity.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/models/models/network.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'account.dart';

class Web3StellarChain extends Web3Chain<StellarAddress, StellarChain,
    Web3StellarChainAccount, WalletStellarNetwork> {
  int _id;
  @override
  int get currentChain => _id;
  Web3StellarChain._(
      {required super.accounts, required int id, required super.activities})
      : _id = id;
  @override
  Web3StellarChain clone() {
    return Web3StellarChain._(
        accounts: activeAccounts,
        id: ChainConst.stellarMainnetId,
        activities: activities);
  }

  factory Web3StellarChain.create({int? id}) {
    return Web3StellarChain._(
        accounts: const [],
        id: id ?? ChainConst.stellarMainnetId,
        activities: const []);
  }

  @override
  List<Web3StellarChainAccount> get activeAccounts =>
      super.activeAccounts.cast();

  factory Web3StellarChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: NetworkType.stellar.tag);
    return Web3StellarChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3StellarChainAccount.deserialize(object: e))
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
  NetworkType get network => NetworkType.stellar;

  @override
  IStellarAddress getAccountPermission(
      {required StellarAddress address, required StellarChain chain}) {
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
  Web3StellarChainAccount? getPermission(StellarAddress address) {
    return activeAccounts.firstWhereOrNull((e) => e.address == address);
  }

  @override
  void setActiveChain(WalletStellarNetwork network) {
    _id = network.value;
  }

  @override
  Web3StellarChain disconnect() {
    return Web3StellarChain._(
        accounts: const [],
        id: ChainConst.stellarMainnetId,
        activities: activities);
  }

  @override
  List<Web3StellarChainAccount> chainAccounts(StellarChain chain) {
    final currentAccounts =
        activeAccounts.where((e) => e.id == chain.network.value).toList();
    final List<Web3StellarChainAccount> existsAccounts = [];
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
  Web3ChainAuthenticated createAuthenticated(
      List<Web3ChainNetworkData<WalletStellarNetwork>> networks) {
    final currentNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final network =
        networks.firstWhere((e) => e.network.value == currentNetwork.value);
    final currentAccounts =
        activeAccounts.where((e) => e.id == currentNetwork.value).toList();
    return Web3StellarChainAuthenticated(
        accounts: currentAccounts,
        network: network.network,
        serviceIdentifier: network.serviceIdentifier);
  }

  @override
  StellarChain getCurrentPermissionChain(List<StellarChain> chain) {
    final currentNetwork =
        getCurrentPermissionNetwork(chain.map((e) => e.network).toList());
    List<Web3StellarChainAccount> accounts = activeAccounts.clone();
    List<Web3StellarChainAccount> existsAccount = [];
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
  WalletStellarNetwork getCurrentPermissionNetwork(
      List<WalletStellarNetwork> networks) {
    final currentChain = _id;
    final network = networks.firstWhereOrNull((e) => e.value == currentChain);
    if (network != null) {
      return network;
    }
    final mainNetwork =
        networks.firstWhere((e) => e.value == ChainConst.stellarMainnetId);
    List<Web3StellarChainAccount> accounts =
        activeAccounts.clone().where((e) => e.id != currentChain).toList();
    setActiveChain(mainNetwork);
    updateChainAccount(accounts);
    return mainNetwork;
  }
}
