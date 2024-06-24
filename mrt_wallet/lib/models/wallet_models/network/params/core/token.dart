import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/app/app_image.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class Token with CborSerializable, Equatable {
  factory Token.fromCborBytesOrObject({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.token);
      final String name = cbor.elementAt(0);
      final String symbol = cbor.elementAt(1);
      final int? decimal = cbor.elementAt(2);
      final String? logo = cbor.elementAt(3);
      final CborTagValue? logoCbor = cbor.getCborTag(3);
      AppImage? image;
      if (logo != null) {
        image = AppImage.local(logo);
      } else if (logoCbor != null) {
        image = AppImage.fromCborBytesOrObject(obj: logoCbor);
      }
      return Token(
          name: name, symbol: symbol, decimal: decimal, assetLogo: image);
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }
  Token._(
      {required this.name, required this.symbol, this.assetLogo, this.decimal});
  factory Token(
      {required String name,
      required String symbol,
      AppImage? assetLogo,
      int? decimal}) {
    if (decimal != null) {
      if (decimal < 0 || decimal > 255) {
        throw WalletExceptionConst.invalidTokenInformation;
      }
    }
    return Token._(
        name: name, symbol: symbol, assetLogo: assetLogo, decimal: decimal);
  }
  Token copyWith({
    String? name,
    String? symbol,
    int? decimal,
    AppImage? assetLogo,
  }) {
    return Token(
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      decimal: decimal ?? this.decimal,
      assetLogo: assetLogo ?? this.assetLogo,
    );
  }

  final String name;
  final String symbol;

  final int? decimal;
  final AppImage? assetLogo;

  late final String nameView = AppStringUtility.substring(name, length: 20);
  late final String symbolView = AppStringUtility.substring(symbol, length: 5);
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          name,
          symbol,
          decimal ?? const CborNullValue(),
          assetLogo?.toCbor() ?? const CborNullValue(),
        ]),
        WalletModelCborTagsConst.token);
  }

  @override
  List get variabels => [name, symbol, decimal];

  @override
  String toString() {
    return "Token: $name";
  }
}
