import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/activity.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:ton_dart/ton_dart.dart';
import 'account.dart';

class Web3TonChain
    extends Web3Chain<TonAddress, TheOpenNetworkChain, Web3TonChainAccount> {
  int _workChain;
  int get currentChain => _workChain;
  Web3TonChain._(
      {required super.accounts,
      required int workChain,
      required super.activities})
      : _workChain = workChain;
  @override
  Web3TonChain clone() {
    return Web3TonChain._(
        accounts: activeAccounts, workChain: 0, activities: activities);
  }

  factory Web3TonChain.create({int? workChain}) {
    return Web3TonChain._(
        accounts: const [], workChain: workChain ?? 0, activities: const []);
  }

  @override
  List<Web3TonChainAccount> get activeAccounts => super.activeAccounts.cast();

  factory Web3TonChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, hex: hex, object: object, tags: NetworkType.ton.tag);
    return Web3TonChain._(
        accounts: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Web3TonChainAccount.deserialize(object: e))
            .toList(),
        workChain: values.elementAt(1),
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
          _workChain,
          CborListValue.fixedLength(activities.map((e) => e.toCbor()).toList()),
        ]),
        network.tag);
  }

  @override
  NetworkType get network => NetworkType.ton;

  @override
  ITonAddress getAccountPermission(
      {required TonAddress address, required TheOpenNetworkChain chain}) {
    try {
      final permissionAccount = activeAccounts.firstWhere((e) =>
          e.address == address &&
          e.workChain == chain.network.coinParam.workchain);
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
  Web3TonChainAccount? getPermission(TonAddress address) {
    return activeAccounts.firstWhereOrNull((e) => e.address == address);
  }

  @override
  void setActiveChain(TheOpenNetworkChain chain) {
    _workChain = chain.network.coinParam.workchain;
  }

  @override
  Web3TonChain disconnect() {
    return Web3TonChain._(
        accounts: const [], workChain: 0, activities: activities);
  }

  @override
  List<Web3TonChainAccount> chainAccounts(TheOpenNetworkChain chain) {
    final currentAccounts = activeAccounts
        .where((e) => e.workChain == chain.network.coinParam.workchain)
        .toList();
    List<Web3TonChainAccount> existsAccounts = [];
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
