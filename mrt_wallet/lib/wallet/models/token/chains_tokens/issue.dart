import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/models/token/core/core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class RippleIssueToken with Equatable implements TokenCore<BigRational> {
  RippleIssueToken._(this.balance, this.token, this.issuer, this._updated);
  factory RippleIssueToken.create(
      {required String balance, required Token token, required String issuer}) {
    final Live<DecimalBalance> liveBalance =
        Live(DecimalBalance.fromString(balance));
    return RippleIssueToken._(liveBalance, token, issuer, DateTime.now());
  }
  factory RippleIssueToken.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, CborTagsConst.rippleIssueToken);

      final Token token = Token.fromCborBytesOrObject(obj: cbor.getCborTag(0));
      final String issuer = cbor.elementAt(1);
      final Live<DecimalBalance> balance =
          Live(DecimalBalance.fromString(cbor.elementAt(2)));
      final DateTime updated = cbor.elementAt(3);
      return RippleIssueToken._(balance, token, issuer, updated);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }
  RippleIssueToken updateToken(Token updateToken) {
    return RippleIssueToken._(balance, updateToken, issuer, _updated);
  }

  @override
  final Live<DecimalBalance> balance;

  DateTime _updated;

  @override
  DateTime get updated => _updated;

  @override
  final String issuer;
  @override
  void updateBalance([BigRational? updateBalance]) {
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
          issuer,
          balance.value.balance.toDecimal(),
          CborEpochIntValue(_updated)
        ]),
        CborTagsConst.rippleIssueToken);
  }

  @override
  List get variabels => [issuer];

  @override
  final Token token;

  @override
  final String? type = null;
}
