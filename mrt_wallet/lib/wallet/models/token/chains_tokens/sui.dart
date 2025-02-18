import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token.dart';

class SuiToken with Equatable implements TokenCore<BigInt> {
  SuiToken._(
      this.balance, this.token, this._updated, this.assetType, this._isFreeze);
  factory SuiToken.create(
      {required BigInt balance,
      required Token token,
      required String assetType,
      bool isFreeze = false}) {
    final Live<IntegerBalance> liveBalance =
        Live(IntegerBalance(balance, token.decimal!));
    return SuiToken._(liveBalance, token, DateTime.now(), assetType, isFreeze);
  }
  factory SuiToken.fromCborBytesOrObject({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue values =
          CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.suiToken);

      final Token token =
          Token.fromCborBytesOrObject(obj: values.getCborTag(0));
      final Live<IntegerBalance> balance =
          Live(IntegerBalance(values.elementAs(1), token.decimal!));
      final DateTime updated = values.elementAs(2);
      final String denom = values.elementAs(3);
      final bool isFreez = values.elementAs<bool?>(4) ?? false;
      return SuiToken._(balance, token, updated, denom, isFreez);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }

  SuiToken updateToken(Token updateToken) {
    return SuiToken.create(
        balance: balance.value.balance,
        token: updateToken,
        assetType: assetType);
  }

  @override
  final Live<IntegerBalance> balance;
  final String assetType;

  DateTime _updated;

  @override
  DateTime get updated => _updated;
  bool _isFreeze;
  bool get isFreeze => _isFreeze;
  void setFreeze(bool freeze) {
    _isFreeze = freeze;
  }

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
          assetType,
          _isFreeze
        ]),
        CborTagsConst.suiToken);
  }

  @override
  List get variabels => [assetType];

  @override
  final Token token;

  @override
  String? get issuer => assetType;

  @override
  late final String? type = "FATs";
}
