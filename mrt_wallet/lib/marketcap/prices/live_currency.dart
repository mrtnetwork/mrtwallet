import 'dart:async';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/marketcap/prices/coingecko.dart';
import 'package:mrt_wallet/repository/repository.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

mixin LiveCurrencies on WalletStateController, ExternalRepository {
  final _lock = SynchronizedLock();
  void _listenOnWallet(WalletEventStaus status) {
    if (status.isOpen) {
      _startListening();
    } else {
      _disposeSteam();
    }
  }

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

  void _startListening() async {
    if (_streamPrices != null) return;
    await _lock.synchronized(() {
      _coinIds ??= coinIds();
      _streamPrices = MethodUtils.prediocCaller<CoingeckoPriceHandler>(
              () async {
        final result = await MethodUtils.call(() async {
          return await getCoinPrices(_coinIds!);
        });
        return result;
      },
              waitOnSuccess: const Duration(minutes: 10),
              waitOnError: const Duration(minutes: 1),
              canclable: _cancelStream)
          .listen(_onUpdatePrices);
    });
  }

  void _disposeSteam() async {
    await _lock.synchronized(() {
      MethodUtils.nullOnException(() {
        _streamPrices?.cancel().catchError((e) => null);
        _streamPrices = null;
        _cancelStream.cancel();
      });
    });
  }

  void changeCurrency(Currency? currency) {
    if (currency == null) return;
    _currenciesPrice.clearCache();
    _currency.value = currency;
  }

  @override
  void ready() {
    super.ready();
    addWalletListener(_listenOnWallet);
  }

  @override
  void close() {
    removeWalletListener(_listenOnWallet);
    super.close();
  }
}
