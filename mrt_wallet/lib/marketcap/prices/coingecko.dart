import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';

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
  final Map<String, IntegerBalance> _caches = {};
  IntegerBalance? getPrice({
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
    _caches[name] ??= _getPrice(
        basePrice: basePrice,
        token: token,
        amount: amount,
        baseCurrency: baseCurrency);

    return _caches[name];
  }

  IntegerBalance _getPrice(
      {required BigRational basePrice,
      required Token token,
      required String amount,
      required Currency baseCurrency}) {
    final BigRational aPrice = BigRational.parseDecimal(amount);
    final val = PriceUtils.decodePrice(
        (basePrice * aPrice).toDecimal(), token.decimal!,
        validateDecimal: false);
    return IntegerBalance(val, token.decimal!,
        decimalPlaces: baseCurrency.decimal);
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
