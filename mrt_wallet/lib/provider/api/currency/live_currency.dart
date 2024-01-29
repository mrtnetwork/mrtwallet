import 'dart:async';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/utility/http/http_caller.dart';
import 'package:mrt_wallet/models/app/app_seting.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

mixin AppCurrencies on StateController {
  String _toName(String currency, String amount, Token token) {
    return "$currency-$amount-${token.name}";
  }

  AppSetting get appSetting;
  final Map<String, NoneDecimalBalance?> _prices = {};
  late final Live<Token> _currency = Live<Token>(appSetting.currency.toToken());
  Token get currencyToken => _currency.value;
  NoneDecimalBalance? amount(String amount, Token token) {
    final Token currency = _currency.value;
    if (currency.symbol.toLowerCase() == token.symbol.toLowerCase()) {
      return null;
    }

    final name = _toName(currency.symbol.toLowerCase(), amount, token);
    return _prices[name] ??= _amount(currency, amount, token);
  }

  NoneDecimalBalance? _amount(Token currency, String amount, Token token) {
    final String? tokenId = CoinGeckoUtils.getCoinGeckoCurrencyId(token.name);

    final String? price =
        _currenciesPrice[tokenId]?[currency.symbol.toLowerCase()]?.toString();
    if (price == null) return null;
    final BigInt priceInCurrency = PriceUtils.convertPrice(
        base: price, amount: amount, decimal: currency.decimal!);

    return NoneDecimalBalance(priceInCurrency, currency.decimal!);
  }

  Map<String, dynamic> _currenciesPrice = {};
  StreamSubscription<Map<String, dynamic>>? _streamPrices;
  final Cancelable _cancelStream = Cancelable();
  void _onUpdatePrices(Map<String, dynamic> result) {
    _currenciesPrice = Map<String, dynamic>.unmodifiable(result);
    _currency.notify();
  }

  void _startListening() {
    final uri = CoinGeckoUtils.toCoingeckoPriceUri(
        Currency.toApiCall(), CoinGeckoUtils.currencyIds.join(","));
    _streamPrices = MethodCaller.prediocCaller<Map<String, dynamic>>(
            () async => await HttpCaller.get<Map<String, dynamic>>(uri),
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
    _prices.clear();
    _currency.value = currency.toToken();
  }

  @override
  void close() {
    _disposeSteam();
    super.close();
  }

  @override
  void ready() {
    super.ready();
    _startListening();
  }
}
