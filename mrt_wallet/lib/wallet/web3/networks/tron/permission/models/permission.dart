import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/networks/tron/tron.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/activity.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:on_chain/on_chain.dart';
import 'account.dart';

class Web3TronChain
    extends Web3Chain<TronAddress, TronChain, Web3TronChainAccount> {
  TronChainType _currentChain;
  TronChainType get currentChain => _currentChain;
  Web3TronChain._(
      {required super.accounts,
      required TronChainType currentChain,
      required super.activities})
      : _currentChain = currentChain;
  @override
  Web3TronChain clone() {
    return Web3TronChain._(
        accounts: activeAccounts,
        currentChain: currentChain,
        activities: activities);
  }

  factory Web3TronChain.create({TronChainType? chain}) {
    return Web3TronChain._(
        accounts: const [],
        currentChain: chain ?? TronChainType.mainnet,
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
        currentChain: TronChainType.fromGenesis(values.elementAt(1)),
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
          _currentChain.genesisBlockNumber,
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
      final permissionAccount = activeAccounts.firstWhere((e) =>
          e.address == address && e.chain == chain.network.tronNetworkType);
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
  void setActiveChain(TronChain chain) {
    _currentChain = chain.network.tronNetworkType;
  }

  @override
  Web3TronChain disconnect() {
    return Web3TronChain._(
        accounts: const [], currentChain: currentChain, activities: activities);
  }

  @override
  List<Web3TronChainAccount> chainAccounts(TronChain chain) {
    final currentAccounts = activeAccounts
        .where((e) => e.chain == chain.network.tronNetworkType)
        .toList();
    List<Web3TronChainAccount> existsAccounts = [];
    for (final i in chain.addresses) {
      final chainAccount = currentAccounts.firstWhereOrNull(
          (e) => e.addressStr == i.address.address && e.keyIndex == i.keyIndex);
      if (chainAccount != null) {
        existsAccounts.add(chainAccount);
      }
    }
    return existsAccounts;
  }
}
