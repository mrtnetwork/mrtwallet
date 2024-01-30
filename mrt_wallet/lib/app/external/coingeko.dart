class CoinGeckoUtils {
  static const String _coingeckoPublicCurrenciesAPI =
      "https://api.coingecko.com/api/v3/simple/price?ids=#ids&vs_currencies=#currencies";
  static const String _coinGeckoCoinURL =
      "https://www.coingecko.com/en/coins/#id";
  static const String logo = "assets/image/coingeko.png";
  static String? getTokenCoinGeckoURL(String tokenName) {
    final currencyId = getCoinGeckoCurrencyId(tokenName);
    if (currencyId == null) return null;
    return _coinGeckoCoinURL.replaceFirst("#id", currencyId);
  }

  static String toCoingeckoPriceUri(String currencies, String ids) {
    return _coingeckoPublicCurrenciesAPI
        .replaceFirst("#currencies", currencies)
        .replaceFirst("#ids", ids);
  }

  static List<String> get currencyIds => _currencyIds.values.toList();

  static Map<String, String> get _currencyIds => {
        "BitcoinCash": "bitcoin-cash",
        "Bitcoin": "bitcoin",
        "Litecoin": "litecoin",
        "Dogecoin": "dogecoin",
        "BitcoinSV": "bitcoin-cash-sv",
        "Dash": "dash",
        "Ripple": "ripple",
        "Ripple testnet": "ripple",
        "Ethereum": "ethereum",
        "Polygon": "matic-network",
        "BNB Smart Chain": "binancecoin",
        "Tron": "tron"
      };
  static String? getCoinGeckoCurrencyId(String tokenName) {
    return _currencyIds[tokenName];
  }
}
