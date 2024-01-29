import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class Token with CborSerializable, Equatable {
  factory Token.fromCborBytesOrObject({List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.token);
      final String name = cbor.getIndex(0);
      final String symbol = cbor.getIndex(1);
      final int? decimal = cbor.getIndex(2);
      final String? logo = cbor.getIndex(3);
      return Token(
          name: name, symbol: symbol, decimal: decimal, assetLogo: logo);
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }
  Token(
      {required this.name, required this.symbol, this.assetLogo, this.decimal});
  Token copyWith({
    String? name,
    String? symbol,
    int? decimal,
    String? assetLogo,
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
  final String? assetLogo;

  late final String nameView = AppStringUtility.substring(name, length: 20);
  late final String symbolView = AppStringUtility.substring(symbol, length: 5);
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          name,
          symbol,
          decimal ?? const CborNullValue(),
          assetLogo ?? const CborNullValue(),
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
