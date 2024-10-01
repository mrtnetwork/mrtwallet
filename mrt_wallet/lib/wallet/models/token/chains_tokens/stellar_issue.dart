import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/models/token/core/core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarIssueToken with Equatable implements TokenCore<BigInt> {
  StellarIssueToken._(
      this.balance, this.token, this.issuer, this._updated, this.assetType);
  factory StellarIssueToken.create({
    required BigInt balance,
    required Token token,
    required String issuer,
    required AssetType assetType,
  }) {
    final Live<IntegerBalance> liveBalance =
        Live(IntegerBalance(balance, token.decimal!));
    return StellarIssueToken._(
        liveBalance, token, issuer, DateTime.now(), assetType);
  }
  factory StellarIssueToken.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, CborTagsConst.stellarIssueToken);

      final Token token = Token.fromCborBytesOrObject(obj: cbor.getCborTag(0));
      final String issuer = cbor.elementAt(1);
      final Live<IntegerBalance> balance =
          Live(IntegerBalance(cbor.elementAt(2), token.decimal!));
      final DateTime updated = cbor.elementAt(3);
      final AssetType assetType = AssetType.fromName(cbor.elementAt(4));
      return StellarIssueToken._(balance, token, issuer, updated, assetType);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }
  StellarIssueToken updateToken(Token updateToken) {
    return StellarIssueToken._(
        balance, updateToken, issuer, _updated, assetType);
  }

  @override
  final Live<IntegerBalance> balance;
  DateTime _updated;
  @override
  DateTime get updated => _updated;
  final AssetType assetType;

  @override
  final String issuer;
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
          assetType.name
        ]),
        CborTagsConst.stellarIssueToken);
  }

  @override
  List get variabels => [issuer, assetType.name, token.name];

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
            code: token.symbol);
      case AssetType.creditAlphanum12:
        return StellarAssetCreditAlphanum12(
            issuer: StellarPublicKey.fromAddress(
                StellarAddress.fromBase32Addr(issuer)),
            code: token.symbol);
      default:
        throw WalletExceptionConst.unsuportedFeature;
    }
    // return
  }
}
