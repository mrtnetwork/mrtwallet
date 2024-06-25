import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/json_serialization.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/currency_balance/balance.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

import 'currencies.dart';

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
        bytes, obj, WalletModelCborTagsConst.coingeckoInfo);
    return CoingeckoCoin(
        apiId: cbor.elementAt(0),
        coinName: cbor.elementAt(1),
        symbol: cbor.elementAt(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([apiId, coinName, symbol]),
        WalletModelCborTagsConst.coingeckoInfo);
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

class CoingeckoCoinInfo {
  final String id;
  final Map<Currency, dynamic> prices;
  CoingeckoCoinInfo({required this.id, required this.prices});
  factory CoingeckoCoinInfo.fromJson(Map<String, dynamic> json, String id) {
    final Map<Currency, dynamic> prices = {};
    for (final i in json.entries) {
      final currency = Currency.fromName(i.key);
      if (currency == null) continue;
      prices[currency] = i.value.toString();
    }
    return CoingeckoCoinInfo(id: id, prices: prices);
  }

  BigRational? getPrice(Currency currency) {
    if (!prices.containsKey(currency)) return null;
    final val = prices[currency]!;
    if (val is String) {
      prices[currency] = BigRational.parseDecimal(val);
    }
    return prices[currency];
  }
}

class CoingeckoPriceHandler {
  Map<String, CoingeckoCoinInfo> _coins;
  CoingeckoPriceHandler(this._coins);
  factory CoingeckoPriceHandler.fromJson(Map<String, dynamic> json) {
    return CoingeckoPriceHandler(json.map(
        (key, value) => MapEntry(key, CoingeckoCoinInfo.fromJson(value, key))));
  }
  final Map<String, NoneDecimalBalance> _caches = {};
  NoneDecimalBalance? getPrice({
    required Currency baseCurrency,
    required Token token,
    required String amount,
  }) {
    if (token.symbol.toUpperCase() == baseCurrency.name) {
      return null;
    }
    final String? apiId = token.market?.apiId;
    final name = "${baseCurrency.name}_${apiId}_$amount";
    final BigRational? basePrice = _coins[apiId]?.getPrice(baseCurrency);
    if (basePrice == null) return null;
    _caches[name] ??=
        _getPrice(basePrice: basePrice, token: token, amount: amount);

    return _caches[name];
  }

  NoneDecimalBalance _getPrice({
    required BigRational basePrice,
    required Token token,
    required String amount,
  }) {
    final BigRational aPrice = BigRational.parseDecimal(amount);
    final val = PriceUtils.decodePrice(
        (basePrice * aPrice).toDecimal(), token.decimal!,
        validateDecimal: false);
    return NoneDecimalBalance(val, token.decimal!);
  }

  void addCoin(CoingeckoCoinInfo newCoin) {
    _coins[newCoin.id] = newCoin;
  }

  void clearCache() {
    _caches.clear();
  }

  CoingeckoCoinInfo? getCoin(String id) {
    return _coins[id];
  }
}

// class CoingeckoCoinCoinList with CborSerializable {
//   final List<CoingeckoCoin> coins;
//   CoingeckoCoinCoinList(List<CoingeckoCoin> coins)
//       : coins = List.unmodifiable(coins);

//   factory CoingeckoCoinCoinList.fromCborBytesOrObject(
//       {List<int>? bytes, CborObject? obj}) {
//     final CborListValue cbor = CborSerializable.decodeCborTags(
//         bytes, obj, WalletModelCborTagsConst.coingeckoCoins);
//     final List<CborObject> coins = cbor.value.cast();
//     return CoingeckoCoinCoinList(
//         coins.map((e) => CoingeckoCoin.fromCborBytesOrObject(obj: e)).toList());
//   }

//   @override
//   CborTagValue toCbor() {
//     return CborTagValue(
//         CborListValue.fixedLength(coins.map((e) => e.toCbor()).toList()),
//         WalletModelCborTagsConst.coingeckoCoins);
//   }
// }

class CoingeckoCoinCoinList with JsonSerialization {
  final List<CoingeckoCoin> coins;
  CoingeckoCoinCoinList(List<CoingeckoCoin> coins)
      : coins = List.unmodifiable(coins);

  factory CoingeckoCoinCoinList.fromJson(Map<String, dynamic> json) {
    return CoingeckoCoinCoinList(
        (json["coins"] as List).map((e) => CoingeckoCoin.fromJson(e)).toList());
  }

  @override
  Map<String, dynamic> toJson() {
    return {"coins": coins.map((e) => e.toJson()).toList()};
  }
}
