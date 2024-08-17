import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';

class TronTRC10Token with Equatable implements TokenCore<BigInt>, TronToken {
  TronTRC10Token._(this.balance, this.token, this.tokenID, this._updated);
  factory TronTRC10Token.create(
      {required BigInt balance,
      required Token token,
      required String tokenID}) {
    final Live<IntegerBalance> liveBalance =
        Live(IntegerBalance(balance, token.decimal!));
    return TronTRC10Token._(liveBalance, token, tokenID, DateTime.now());
  }
  factory TronTRC10Token.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor =
          CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.trc10Token);

      final Token token = Token.fromCborBytesOrObject(obj: cbor.getCborTag(0));
      final String tokenID = cbor.elementAt(1);
      final Live<IntegerBalance> balance =
          Live(IntegerBalance(cbor.elementAt(2), token.decimal!));
      final DateTime updated = cbor.elementAt(3);
      return TronTRC10Token._(balance, token, tokenID, updated);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }
  TronTRC10Token updateToken(Token updateToken) {
    return TronTRC10Token._(balance, updateToken, tokenID, _updated);
  }

  @override
  final Live<IntegerBalance> balance;

  DateTime _updated;

  @override
  DateTime get updated => _updated;

  final String tokenID;
  @override
  void updateBalance([BigInt? updateBalance]) {
    balance.value.updateBalance(updateBalance);
    if (updateBalance != null) {
      _updated = DateTime.now().toLocal();
      balance.notify();
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          token.toCbor(),
          tokenID,
          balance.value.balance,
          CborEpochIntValue(_updated)
        ]),
        CborTagsConst.trc10Token);
  }

  @override
  List get variabels => [tokenID];

  @override
  final Token token;

  @override
  String? get issuer => tokenID;

  @override
  late final String? type = "trc10";
}
