import 'dart:async';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/marketcap/prices/coingecko.dart';
import 'package:mrt_wallet/repository/repository.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';

mixin LiveCurrencies on StateController, ExternalRepository {
  List<String> coinIds();
  APPSetting get appSetting;
  late final Live<Currency> _currency = Live<Currency>(appSetting.currency);
  Currency get currencyToken => _currency.value;
  List<String>? _coinIds;
  IntegerBalance? amount(String amount, Token token) {
    return _currenciesPrice.getPrice(
        baseCurrency: currencyToken, token: token, amount: amount);
  }

  @override
  Future<CoingeckoCoinInfo?> getCoinPrice(String id) async {
    CoingeckoCoinInfo? coin = _currenciesPrice.getCoin(id);
    coin ??= await super.getCoinPrice(id);
    _currenciesPrice.addCoin(coin!);
    return coin;
  }

  CoingeckoPriceHandler _currenciesPrice = CoingeckoPriceHandler({});
  StreamSubscription<CoingeckoPriceHandler>? _streamPrices;
  final Cancelable _cancelStream = Cancelable();
  void _onUpdatePrices(CoingeckoPriceHandler result) {
    _currenciesPrice = result;
    _currency.notify();
  }

  void _startListening() {
    _coinIds ??= coinIds();
    _streamPrices = MethodUtils.prediocCaller<CoingeckoPriceHandler>(() async {
      final result = await MethodUtils.call(() async {
        return await getCoinPrices(_coinIds!);
      });
      return result;
    },
            waitOnSuccess: const Duration(minutes: 10),
            waitOnError: const Duration(minutes: 1),
            canclable: _cancelStream)
        .listen(_onUpdatePrices);
  }

  void _disposeSteam() {
    _streamPrices?.cancel().catchError((e) => null);
    _streamPrices = null;
    _cancelStream.cancel();
  }

  void changeCurrency(Currency? currency) {
    if (currency == null) return;
    _currenciesPrice.clearCache();
    _currency.value = currency;
  }

  @override
  void ready() {
    super.ready();
    _startListening();
  }

  @override
  void close() {
    _disposeSteam();
    super.close();
  }
}
