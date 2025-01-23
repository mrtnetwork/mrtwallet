import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';

class CW20Token with Equatable implements TokenCore<BigInt> {
  CW20Token._(this.balance, this.token, this._updated, this.denom);
  factory CW20Token.create({
    required BigInt balance,
    required Token token,
    required String denom,
  }) {
    final Live<IntegerBalance> liveBalance =
        Live(IntegerBalance(balance, token.decimal!));
    return CW20Token._(liveBalance, token, DateTime.now(), denom);
  }
  factory CW20Token.fromCborBytesOrObject({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue values =
          CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.cw20);

      final Token token =
          Token.fromCborBytesOrObject(obj: values.getCborTag(0));
      final Live<IntegerBalance> balance =
          Live(IntegerBalance(values.elementAs(1), token.decimal!));
      final DateTime updated = values.elementAs(2);
      final String denom = values.elementAs(3);
      return CW20Token._(balance, token, updated, denom);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }

  CW20Token updateToken(Token updateToken) {
    return CW20Token.create(
        balance: balance.value.balance, token: updateToken, denom: denom);
  }

  @override
  final Live<IntegerBalance> balance;
  final String denom;

  DateTime _updated;

  @override
  DateTime get updated => _updated;

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
          balance.value.balance,
          CborEpochIntValue(_updated),
          denom
        ]),
        CborTagsConst.cw20);
  }

  @override
  List get variabels => [denom];

  @override
  final Token token;

  @override
  String? get issuer => denom;

  @override
  late final String? type = "CW20";
}
