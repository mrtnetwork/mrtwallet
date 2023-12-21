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
      return Token(name: name, symbol: symbol, decimal: decimal, logo: logo);
    } catch (e) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
  }
  const Token(
      {required this.name, required this.symbol, this.logo, this.decimal});

  final String name;
  final String symbol;

  final int? decimal;
  final String? logo;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          name,
          symbol,
          decimal ?? const CborNullValue(),
          logo ?? const CborNullValue(),
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
