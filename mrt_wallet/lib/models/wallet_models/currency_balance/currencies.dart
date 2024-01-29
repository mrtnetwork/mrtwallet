import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';

enum Currency {
  btc("Bitcoin", 8),
  eth("Ethereum", 18),
  ltc("Litecoin", 8),
  bch("Bitcoin Cash", 8),
  bnb("Binance Coin", 18),
  eos("EOS", 4),
  xrp("XRP", 6),
  xlm("Stellar", 7),
  link("Chainlink", 18),
  dot("Polkadot", 10),
  yfi("yearn.finance", 18),
  usd("United States Dollar", 2),
  aed("United Arab Emirates Dirham", 2),
  ars("Argentine Peso", 2),
  aud("Australian Dollar", 2),
  bdt("Bangladeshi Taka", 2),
  bhd("Bahraini Dinar", 3),
  bmd("Bermudian Dollar", 2),
  brl("Brazilian Real", 2),
  cad("Canadian Dollar", 2),
  chf("Swiss Franc", 2),
  clp("Chilean Peso", 2),
  cny("Chinese Yuan", 2),
  czk("Czech Koruna", 2),
  dkk("Danish Krone", 2),
  eur("Euro", 2),
  gbp("British Pound Sterling", 2),
  gel("Georgian Lari", 2),
  hkd("Hong Kong Dollar", 2),
  huf("Hungarian Forint", 2),
  idr("Indonesian Rupiah", 2),
  ils("Israeli New Shekel", 2),
  inr("Indian Rupee", 2),
  jpy("Japanese Yen", 0),
  krw("South Korean Won", 0),
  kwd("Kuwaiti Dinar", 3),
  lkr("Sri Lankan Rupee", 2),
  mmk("Myanmar Kyat", 2),
  mxn("Mexican Peso", 2),
  myr("Malaysian Ringgit", 2),
  ngn("Nigerian Naira", 2),
  nok("Norwegian Krone", 2),
  nzd("New Zealand Dollar", 2),
  php("Philippine Peso", 2),
  pkr("Pakistani Rupee", 2),
  pln("Polish Złoty", 2),
  rub("Russian Ruble", 2),
  sar("Saudi Riyal", 2),
  sek("Swedish Krona", 2),
  sgd("Singapore Dollar", 2),
  thb("Thai Baht", 2),
  try_("Turkish Lira", 2),
  twd("New Taiwan Dollar", 2),
  uah("Ukrainian Hryvnia", 2),
  vef("Venezuelan Bolívar", 2),
  vnd("Vietnamese Đồng", 2),
  zar("South African Rand", 2),
  xdr("Special Drawing Rights (SDR)", 2),
  xag("Silver (measured in troy ounces)", 2),
  xau("Gold (measured in troy ounces)", 2);

  final String currencyName;
  final int decimal;

  const Currency(this.currencyName, this.decimal);

  Token toToken() {
    return Token(
        name: currencyName, symbol: name.toUpperCase(), decimal: decimal);
  }

  static String toApiCall() {
    return values.map((e) => e.name).join(",");
  }

  static Currency fromName(String? name) {
    return values.firstWhere((element) => element.name == name,
        orElse: () => Currency.usd);
  }
}
