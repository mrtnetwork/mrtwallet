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
import 'package:polkadot_dart/polkadot_dart.dart';
import 'account.dart';

class Web3SubstrateChain extends Web3Chain<BaseSubstrateAddress, SubstrateChain,
    Web3SubstrateChainAccount, WalletSubstrateNetwork> {
  int _id;
  @override
  int get currentChain => _id;
  Web3SubstrateChain._(
      {required super.accounts, required int id, required super.activities})
      : _id = id;
  @override
  Web3SubstrateChain clone() {
    return Web3SubstrateChain._(
        accounts: activeAccounts,
        id: ChainConst.polkadotMainnetId,
        activities: activities);
  }

  factory Web3SubstrateChain.create({int? id}) {
    return Web3SubstrateChain._(
        accounts: const [],
        id: id ?? ChainConst.polkadotMainnetId,
        activities: const []);
  }

  @override
  List<Web3SubstrateChainAccount> get activeAccounts =>
      super.activeAccounts.cast();

  factory Web3SubstrateChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: NetworkType.substrate.tag);
    return Web3SubstrateChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3SubstrateChainAccount.deserialize(object: e))
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
  NetworkType get network => NetworkType.substrate;

  @override
  ISubstrateAddress getAccountPermission(
      {required BaseSubstrateAddress address, required SubstrateChain chain}) {
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
  Web3SubstrateChainAccount? getPermission(BaseSubstrateAddress address) {
    return activeAccounts.firstWhereOrNull((e) => e.address == address);
  }

  @override
  void setActiveChain(WalletSubstrateNetwork network) {
    _id = network.value;
  }

  @override
  Web3SubstrateChain disconnect() {
    return Web3SubstrateChain._(
        accounts: const [],
        id: ChainConst.polkadotMainnetId,
        activities: activities);
  }

  @override
  List<Web3SubstrateChainAccount> chainAccounts(SubstrateChain chain) {
    final currentAccounts =
        activeAccounts.where((e) => e.id == chain.network.value).toList();
    final List<Web3SubstrateChainAccount> existsAccounts = [];
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
      List<Web3ChainNetworkData<WalletSubstrateNetwork>> networks) {
    final mainNetwork =
        getCurrentPermissionNetwork(networks.map((e) => e.network).toList());
    final network = networks.firstWhere(
        (e) => e.network.value == mainNetwork.value,
        orElse: () => throw Web3RequestExceptionConst.invalidNetwork);
    final currentAccounts =
        activeAccounts.where((e) => e.id == mainNetwork.value).toList();
    return Web3SubstrateChainAuthenticated(
        accounts: currentAccounts,
        network: network.network,
        serviceIdentifier: network.serviceIdentifier,
        knownMetadata: networks
            .map((e) => Web3SubstrateChainMetadata(
                genesisHash: e.network.genesisBlock,
                specVersion: e.network.coinParam.specVersion))
            .toList());
  }

  @override
  SubstrateChain getCurrentPermissionChain(List<SubstrateChain> chain) {
    final currentNetwork =
        getCurrentPermissionNetwork(chain.map((e) => e.network).toList());
    List<Web3SubstrateChainAccount> accounts = activeAccounts.clone();
    List<Web3SubstrateChainAccount> existsAccount = [];
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
  WalletSubstrateNetwork getCurrentPermissionNetwork(
      List<WalletSubstrateNetwork> networks) {
    final currentChain = _id;
    final network = networks.firstWhereOrNull((e) => e.value == currentChain);
    if (network != null) {
      return network;
    }
    final mainNetwork =
        networks.firstWhere((e) => e.value == ChainConst.polkadotMainnetId);
    List<Web3SubstrateChainAccount> accounts =
        activeAccounts.clone().where((e) => e.id != currentChain).toList();
    setActiveChain(mainNetwork);
    updateChainAccount(accounts);
    return mainNetwork;
  }
}
