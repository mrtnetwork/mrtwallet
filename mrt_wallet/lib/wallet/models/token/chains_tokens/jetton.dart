import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';
import 'package:ton_dart/ton_dart.dart';

class TonJettonToken with Equatable implements TokenCore<BigInt> {
  TonJettonToken._(
      {required this.balance,
      required this.token,
      required this.minterAddress,
      required this.walletAddress,
      required DateTime updated,
      required this.description,
      required this.uri,
      required this.verified})
      : _updated = updated;
  factory TonJettonToken.create({
    required BigInt balance,
    required Token token,
    required TonAddress minterAddress,
    required TonAddress walletAddress,
    required bool verified,
    String? description,
    String? uri,
  }) {
    final Live<IntegerBalance> liveBalance =
        Live(IntegerBalance(balance, token.decimal!));
    return TonJettonToken._(
        balance: liveBalance,
        token: token,
        minterAddress: minterAddress,
        walletAddress: walletAddress,
        updated: DateTime.now(),
        description: description,
        uri: uri,
        verified: verified);
  }
  factory TonJettonToken.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, CborTagsConst.jettonToken);

      final Token token = Token.fromCborBytesOrObject(obj: cbor.getCborTag(0));
      final String minterAddress = cbor.elementAt(1);
      final String walletAddress = cbor.elementAt(2);
      final Live<IntegerBalance> balance =
          Live(IntegerBalance(cbor.elementAt(3), token.decimal!));
      final DateTime updated = cbor.elementAt(4);
      return TonJettonToken._(
          balance: balance,
          token: token,
          minterAddress: TonAddress(minterAddress),
          walletAddress: TonAddress(walletAddress),
          updated: updated,
          description: cbor.elementAt(5),
          uri: cbor.elementAt(6),
          verified: cbor.elementAt(7));
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }

  @override
  final Live<IntegerBalance> balance;

  DateTime _updated;

  @override
  DateTime get updated => _updated;

  final TonAddress minterAddress;
  final TonAddress walletAddress;

  final String? description;
  final String? uri;
  final bool verified;

  @override
  void updateBalance([BigInt? updateBalance]) {
    balance.value.updateBalance(updateBalance);
    if (updateBalance != null) {
      _updated = DateTime.now().toLocal();
      balance.notify();
    }
  }

  TonJettonToken updateToken(Token updateToken) {
    return TonJettonToken._(
        balance:
            Live(IntegerBalance(balance.value.balance, updateToken.decimal!)),
        token: updateToken,
        minterAddress: minterAddress,
        walletAddress: walletAddress,
        updated: updated,
        description: description,
        uri: uri,
        verified: verified);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          token.toCbor(),
          minterAddress.toFriendlyAddress(),
          walletAddress.toFriendlyAddress(),
          balance.value.balance,
          CborEpochIntValue(_updated),
          description ?? const CborNullValue(),
          uri ?? const CborNullValue(),
          verified
        ]),
        CborTagsConst.jettonToken);
  }

  @override
  List get variabels => [minterAddress, walletAddress];

  @override
  final Token token;

  @override
  String? get issuer => minterAddress.toFriendlyAddress();

  @override
  late final String? type = "Jetton";
}
