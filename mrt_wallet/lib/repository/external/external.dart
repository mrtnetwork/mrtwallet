part of 'package:mrt_wallet/repository/repository.dart';

mixin ExternalRepository on BaseRepository {
  Future<CoingeckoPriceHandler> getCoinPrices(List<String> coins) async {
    final url = CoinGeckoUtils.toCoingeckoPriceUri(
        Currency.toApiCall(), coins.join(","));
    final json = await HttpUtils.get<Map<String, dynamic>>(url);
    return CoingeckoPriceHandler.fromJson(json.result);
  }

  Future<CoingeckoCoinInfo?> getCoinPrice(String id) async {
    final url = CoinGeckoUtils.toCoingeckoPriceUri(Currency.toApiCall(), id);
    final json = await HttpUtils.get<Map<String, dynamic>>(url);
    if (json.result.isEmpty) return null;
    return CoingeckoCoinInfo.fromJson(json.result[id]!, id);
  }
}
