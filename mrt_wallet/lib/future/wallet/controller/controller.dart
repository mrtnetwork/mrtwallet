import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart'
    show APPSetting, StateConst, ThemeController;
import 'package:mrt_wallet/future/widgets/custom_widgets.dart'
    show PageProgressBaseState;
import 'package:mrt_wallet/app/models/models/currencies.dart';
import 'package:mrt_wallet/marketcap/prices/live_currency.dart';
import 'package:mrt_wallet/repository/repository.dart';
import 'package:mrt_wallet/wallet/provider/wallet_provider.dart'
    show WalletCore;

class WalletProvider extends WalletCore
    with ExternalRepository, APPRepository, LiveCurrencies {
  WalletProvider(super._navigatorKey, this._appSetting);

  @override
  final GlobalKey<PageProgressBaseState> pageStatusHandler =
      GlobalKey<PageProgressBaseState>(debugLabel: "WalletProvider");
  APPSetting _appSetting;
  @override
  APPSetting get appSetting => _appSetting;

  void toggleBrightness() {
    network;
    ThemeController.toggleBrightness();
    notify(StateConst.main);
    _appSetting = _appSetting.copyWith(
        appBrightness: ThemeController.appBrightness,
        appColor: ThemeController.appColorHex);
    saveAppSetting(_appSetting);
  }

  void changeColor(Color color) {
    ThemeController.changeColor(color);
    notify(StateConst.main);
    _appSetting = _appSetting.copyWith(
        appBrightness: ThemeController.appBrightness,
        appColor: ThemeController.appColorHex);
    saveAppSetting(_appSetting);
  }

  @override
  void changeCurrency(Currency? currency) {
    if (currency == null || _appSetting.currency == currency) return;
    super.changeCurrency(currency);
    _appSetting = _appSetting.copyWith(currency: currency);
    saveAppSetting(_appSetting);
  }

  @override
  String get repositoryId => StateConst.main;
}
