import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/models/app/material.dart';

import 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

class WalletProvider extends WalletCore {
  WalletProvider(super._navigatorKey);

  @override
  final GlobalKey<PageProgressState> pageStatusHandler =
      GlobalKey<PageProgressState>(debugLabel: "WalletProvider");

  void toggleBrightness() {
    AppMaterialController.toggleBrightness();
    notify(StateIdsConst.main);
    write(
        key: StorageKeysConst.appMaterial,
        value: AppMaterialController.toCbor().toCborHex());
  }

  void changeColor(Color color) {
    AppMaterialController.changeColor(color);
    notify(StateIdsConst.main);
    write(
        key: StorageKeysConst.appMaterial,
        value: AppMaterialController.toCbor().toCborHex());
  }

  @override
  String get repositoryId => StateIdsConst.main;
}
