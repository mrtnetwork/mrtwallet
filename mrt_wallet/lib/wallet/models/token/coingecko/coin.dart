import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/external/coingeko/coingeko.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class CoingeckoCoin with CborSerializable, JsonSerialization {
  final String apiId;
  final String? coinName;
  final String? symbol;
  const CoingeckoCoin({required this.apiId, this.coinName, this.symbol});
  factory CoingeckoCoin.fromJson(Map<String, dynamic> json) {
    return CoingeckoCoin(
        apiId: json["id"], coinName: json["name"], symbol: json["symbol"]);
  }

  factory CoingeckoCoin.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.coingeckoInfo);
    return CoingeckoCoin(
        apiId: cbor.elementAt(0),
        coinName: cbor.elementAt(1),
        symbol: cbor.elementAt(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([apiId, coinName, symbol]),
        CborTagsConst.coingeckoInfo);
  }

  String? get marketUri {
    if (coinName == null) return null;
    return CoinGeckoUtils.getTokenCoinGeckoURL(coinName!);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"id": apiId, "name": coinName, "symbol": symbol};
  }
}
