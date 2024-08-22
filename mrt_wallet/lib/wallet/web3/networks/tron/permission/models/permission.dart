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
        accounts: accounts, currentChain: currentChain, activities: activities);
  }

  factory Web3TronChain.create({TronChainType? chain}) {
    return Web3TronChain._(
        accounts: const [],
        currentChain: chain ?? TronChainType.mainnet,
        activities: const []);
  }

  @override
  List<Web3TronChainAccount> get accounts => super.accounts.cast();

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
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          _currentChain,
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
      final permissionAccount =
          accounts.firstWhere((e) => e.address == address);
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
  List<Web3TronChainAccount> currentChainAccounts(TronChain chain) {
    final currentAccounts =
        accounts.where((e) => e.chain == _currentChain).toList();
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

  @override
  Web3TronChainAccount? getPermission(TronAddress address) {
    return accounts.firstWhereOrNull((e) => e.address == address);
  }

  void updateChain(TronChain chain) {
    _currentChain = chain.network.tronNetworkType;
  }

  @override
  Web3TronChain disconnect() {
    return Web3TronChain._(
        accounts: const [], currentChain: currentChain, activities: activities);
  }

  @override
  bool hasPermission(TronChain chain) => currentChainAccounts(chain).isNotEmpty;
}
