import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart'
    show APPSetting, RepositoryConst, StateConst;
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/app/models/models/currencies.dart';
import 'package:mrt_wallet/marketcap/prices/live_currency.dart';
import 'package:mrt_wallet/repository/repository.dart';
import 'wallet/ui_wallet.dart';

import 'wallet/cross/cross.dart'
    if (dart.library.js_interop) 'wallet/cross/web.dart'
    if (dart.library.io) 'wallet/cross/io.dart';

class WalletProvider extends StateController
    with BaseRepository, APPRepository, LiveCurrencies {
  WalletProvider(GlobalKey<NavigatorState> navigatorKey, this._appSetting)
      : wallet = uiWallet(navigatorKey);

  ThemeData get theme => ThemeController.appTheme;
  GlobalKey<NavigatorState> get navigatorKey => wallet.navigatorKey;
  @override
  final UIWallet wallet;

  APPSetting _appSetting;
  @override
  APPSetting get appSetting => _appSetting;

  void toggleBrightness() {
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
  String get repositoryStorageId => RepositoryConst.appStorageKeyId;

  @override
  void init() {
    super.init();
    wallet.init(notify);
  }

  @override
  void close() {
    super.close();
    wallet.close();
  }
}
