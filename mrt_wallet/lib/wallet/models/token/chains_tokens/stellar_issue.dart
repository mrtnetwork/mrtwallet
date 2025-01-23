import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/models/token/core/core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarIssueToken with Equatable implements TokenCore<BigInt> {
  StellarIssueToken._(this.balance, this.token, this.issuer, this._updated,
      this.assetType, this.assetCode);
  factory StellarIssueToken.create(
      {required BigInt balance,
      required Token token,
      required String issuer,
      required AssetType assetType,
      required String assetCode}) {
    final Live<IntegerBalance> liveBalance =
        Live(IntegerBalance(balance, token.decimal!));
    return StellarIssueToken._(
        liveBalance, token, issuer, DateTime.now(), assetType, assetCode);
  }
  factory StellarIssueToken.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue values = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.stellarIssueToken);

      final Token token =
          Token.fromCborBytesOrObject(obj: values.getCborTag(0));
      final String issuer = values.elementAs(1);
      final Live<IntegerBalance> balance =
          Live(IntegerBalance(values.elementAs(2), token.decimal!));
      final DateTime updated = values.elementAs(3);
      final AssetType assetType = AssetType.fromName(values.elementAs(4));
      return StellarIssueToken._(
          balance, token, issuer, updated, assetType, values.elementAs(5));
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }
  StellarIssueToken updateToken(Token updateToken) {
    if (updateToken.decimal != token.decimal) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
    return StellarIssueToken._(
        balance, updateToken, issuer, _updated, assetType, assetCode);
  }

  @override
  final Live<IntegerBalance> balance;
  DateTime _updated;
  @override
  DateTime get updated => _updated;
  final AssetType assetType;
  @override
  final String issuer;

  final String assetCode;
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
          issuer,
          balance.value.balance,
          CborEpochIntValue(_updated),
          assetType.name,
          assetCode
        ]),
        CborTagsConst.stellarIssueToken);
  }

  @override
  List get variabels => [issuer, assetType.name, assetCode];

  @override
  final Token token;

  @override
  String? get type => assetType.name;

  StellarAsset toStellarAsset() {
    switch (assetType) {
      case AssetType.creditAlphanum4:
        return StellarAssetCreditAlphanum4(
            issuer: StellarPublicKey.fromAddress(
                StellarAddress.fromBase32Addr(issuer)),
            code: assetCode);
      case AssetType.creditAlphanum12:
        return StellarAssetCreditAlphanum12(
            issuer: StellarPublicKey.fromAddress(
                StellarAddress.fromBase32Addr(issuer)),
            code: assetCode);
      default:
        throw WalletExceptionConst.unsuportedFeature;
    }
  }
}
