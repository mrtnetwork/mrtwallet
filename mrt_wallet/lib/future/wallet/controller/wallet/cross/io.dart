import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/wallet/ui_wallet.dart';

UIWallet uiWallet(GlobalKey<NavigatorState> navigatorKey) =>
    Wallet(navigatorKey);

class Wallet extends UIWallet {
  Wallet(GlobalKey<NavigatorState> navigatorKey) : super(navigatorKey);
}
