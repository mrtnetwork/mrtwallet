import 'dart:async';

import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'core.dart' as life_cycle;

typedef FuncWalletLockTime = WalletLockTime? Function();

class LifeCycleTracker {
  LifeCycleTracker(this._onTimer, this._onLockTime);
  late final life_cycle.AppLifecycleListener _listener =
      life_cycle.AppLifecycleListener.instance(_onHide, _onFocus);

  void _onHide() {
    _setupTimer(_onLockTime());
  }

  void _onFocus() {
    _stopTimer();
  }

  void init() {
    _listener.init();
  }

  void dispose() {
    _listener.dispose();
  }

  Timer? _timer;
  final DynamicVoid _onTimer;
  final FuncWalletLockTime _onLockTime;
  Timer _buildTimer(WalletLockTime t) {
    return Timer(Duration(seconds: t.value), _onTimer);
  }

  void _setupTimer(WalletLockTime? lockTime) {
    if (_timer != null || lockTime == null) return;
    if (lockTime.value == 0) return;
    _timer?.cancel();
    _timer = null;
    _timer = _buildTimer(lockTime);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
