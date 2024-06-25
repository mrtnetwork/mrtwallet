import 'package:flutter/material.dart';

import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/app/app_seting.dart';
import 'package:mrt_wallet/models/app/material.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/currency/live_currency.dart';
import 'package:mrt_wallet/provider/repository/repository.dart';

import 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

class WalletProvider extends WalletCore
    with ExternalRepository, APPRepository, AppCurrencies {
  WalletProvider(super._navigatorKey, this._appSetting);

  @override
  final GlobalKey<PageProgressState> pageStatusHandler =
      GlobalKey<PageProgressState>(debugLabel: "WalletProvider");
  AppSetting _appSetting;
  @override
  AppSetting get appSetting => _appSetting;

  void toggleBrightness() {
    network;
    AppMaterialController.toggleBrightness();
    notify(StateIdsConst.main);
    _appSetting = _appSetting.copyWith(
        appBrightness: AppMaterialController.appBrightness,
        appColor: AppMaterialController.appColorHex);
    saveAppSetting(_appSetting);
  }

  void changeColor(Color color) {
    AppMaterialController.changeColor(color);
    notify(StateIdsConst.main);
    _appSetting = _appSetting.copyWith(
        appBrightness: AppMaterialController.appBrightness,
        appColor: AppMaterialController.appColorHex);
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
  String get repositoryId => StateIdsConst.main;
}
