import 'dart:async';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/app/app_seting.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/repository/repository.dart';

mixin AppCurrencies on StateController, ExternalRepository {
  List<String> coinIds();
  AppSetting get appSetting;
  late final Live<Currency> _currency = Live<Currency>(appSetting.currency);
  Currency get currencyToken => _currency.value;
  List<String>? _coinIds;
  NoneDecimalBalance? amount(String amount, Token token) {
    return _currenciesPrice.getPrice(
        baseCurrency: currencyToken, token: token, amount: amount);
  }

  @override
  Future<CoingeckoCoinInfo?> getCoinPrice(String id) async {
    CoingeckoCoinInfo? coin = _currenciesPrice.getCoin(id);
    coin ??= await super.getCoinPrice(id);
    if (coin == null) return null;
    _currenciesPrice.addCoin(coin);
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
    _streamPrices = MethodCaller.prediocCaller<CoingeckoPriceHandler>(() async {
      final result = await MethodCaller.call(() async {
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
