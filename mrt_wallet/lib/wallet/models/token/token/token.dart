import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/app/models/models/image.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/app/utils/string/utils.dart';
import 'package:mrt_wallet/wallet/models/token/coingecko/coin.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class Token with CborSerializable, Equatable {
  final String name;
  final String symbol;
  final int? decimal;
  final APPImage? assetLogo;
  final String nameView;
  final String symbolView;
  final CoingeckoCoin? market;
  bool get hasDecimal => decimal != null;
  factory Token.fromCborBytesOrObject({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor =
          CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.token);
      final String name = cbor.elementAt(0);
      final String symbol = cbor.elementAt(1);
      final int? decimal = cbor.elementAt(2);
      final String? logo = cbor.elementAt(3);
      final CoingeckoCoin? market = cbor
          .getCborTag(4)
          ?.to<CoingeckoCoin, CborObject>(
              (e) => CoingeckoCoin.fromCborBytesOrObject(obj: e));

      final CborTagValue? logoCbor = cbor.getCborTag(3);
      APPImage? image;
      if (logo != null) {
        image = APPImage.local(logo);
      } else if (logoCbor != null) {
        image = APPImage.fromCborBytesOrObject(obj: logoCbor);
      }
      return Token(
          name: name,
          symbol: symbol,
          decimal: decimal,
          assetLogo: image,
          market: market);
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }
  const Token._(
      {required this.name,
      required this.symbol,
      required this.nameView,
      required this.symbolView,
      this.assetLogo,
      this.decimal,
      this.market});
  factory Token(
      {required String name,
      required String symbol,
      APPImage? assetLogo,
      int? decimal,
      CoingeckoCoin? market}) {
    if (decimal != null) {
      if (decimal < 0 || decimal > 255) {
        throw WalletExceptionConst.invalidTokenInformation;
      }
    }
    final String nameView = StrUtils.substring(name, length: 20);
    final String symbolView = StrUtils.substring(symbol, length: 5);
    return Token._(
        name: name,
        symbol: symbol,
        assetLogo: assetLogo,
        decimal: decimal,
        market: market,
        nameView: nameView,
        symbolView: symbolView);
  }
  Token copyWith({
    String? name,
    String? symbol,
    int? decimal,
    APPImage? assetLogo,
    CoingeckoCoin? market,
  }) {
    return Token(
        name: name ?? this.name,
        symbol: symbol ?? this.symbol,
        decimal: decimal ?? this.decimal,
        assetLogo: assetLogo ?? this.assetLogo,
        market: market ?? this.market);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          name,
          symbol,
          decimal ?? const CborNullValue(),
          assetLogo?.toCbor() ?? const CborNullValue(),
          market?.toCbor() ?? const CborNullValue()
        ]),
        CborTagsConst.token);
  }

  @override
  List get variabels => [name, symbol, decimal];

  String? get marketUri {
    return market?.marketUri;
  }

  @override
  String toString() {
    return "Token: $name";
  }
}
