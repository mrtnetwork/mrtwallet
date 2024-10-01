import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/activity.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/chain.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'account.dart';

class Web3StellarChain
    extends Web3Chain<StellarAddress, StellarChain, Web3StellarChainAccount> {
  String _passphrase;
  String get currentChain => _passphrase;
  Web3StellarChain._(
      {required super.accounts,
      required String passphrase,
      required super.activities})
      : _passphrase = passphrase;
  @override
  Web3StellarChain clone() {
    return Web3StellarChain._(
        accounts: activeAccounts,
        passphrase: StellarNetwork.mainnet.passphrase,
        activities: activities);
  }

  factory Web3StellarChain.create({String? passphrase}) {
    return Web3StellarChain._(
        accounts: const [],
        passphrase: passphrase ?? StellarNetwork.mainnet.passphrase,
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
        passphrase: values.elementAt(1),
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
          _passphrase,
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
      final permissionAccount = activeAccounts.firstWhere((e) =>
          e.address == address &&
          e.passphrase == chain.network.coinParam.passphrase);
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
  void setActiveChain(StellarChain chain) {
    _passphrase = chain.network.coinParam.passphrase;
  }

  @override
  Web3StellarChain disconnect() {
    return Web3StellarChain._(
        accounts: const [],
        passphrase: StellarNetwork.mainnet.passphrase,
        activities: activities);
  }

  @override
  List<Web3StellarChainAccount> chainAccounts(StellarChain chain) {
    final currentAccounts = activeAccounts
        .where((e) => e.passphrase == chain.network.coinParam.passphrase)
        .toList();
    List<Web3StellarChainAccount> existsAccounts = [];
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
