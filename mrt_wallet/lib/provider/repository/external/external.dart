part of 'package:mrt_wallet/provider/repository/repository.dart';

mixin ExternalRepository on BaseRepository {
  String get _externalStorageId => StorageKeysConst.external;
  Future<CoingeckoCoinCoinList> getCoinGeckoCoinList() async {
    final data = await MethodCaller.call(() async {
      final storageData = await _read(
          key: StorageKeysConst.coingeckoCoins, storageId: _externalStorageId);
      final json = StringUtils.toJson(storageData!);
      return CoingeckoCoinCoinList.fromJson(json);
    });
    if (data.hasResult) return data.result;
    final result =
        await HttpCaller.get<List>(CoinGeckoUtils.coinGeckoCoinListURL);
    final coins = CoingeckoCoinCoinList(
        result.result.map((e) => CoingeckoCoin.fromJson(e)).toList());
    await _write(
        key: StorageKeysConst.coingeckoCoins,
        value: StringUtils.fromJson(coins.toJson()),
        storageId: _externalStorageId);
    return coins;
  }

  Future<CoingeckoPriceHandler> getCoinPrices(List<String> coins) async {
    final url = CoinGeckoUtils.toCoingeckoPriceUri(
        Currency.toApiCall(), coins.join(","));
    final json = await HttpCaller.get<Map<String, dynamic>>(url);
    return CoingeckoPriceHandler.fromJson(json.result);
  }

  Future<CoingeckoCoinInfo?> getCoinPrice(String id) async {
    final url = CoinGeckoUtils.toCoingeckoPriceUri(Currency.toApiCall(), id);
    final json = await HttpCaller.get<Map<String, dynamic>>(url);
    if (json.result.isEmpty) return null;
    return CoingeckoCoinInfo.fromJson(json.result[id]!, id);
  }
}
