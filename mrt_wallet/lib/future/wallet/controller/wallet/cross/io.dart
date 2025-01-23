import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/wallet/ui_wallet.dart';

UIWallet uiWallet(GlobalKey<NavigatorState> navigatorKey, int storageVersion) =>
    Wallet(navigatorKey: navigatorKey, storageVersion: storageVersion);

class Wallet extends UIWallet {
  Wallet({required super.navigatorKey, required super.storageVersion});
}
