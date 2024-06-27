import 'dart:async';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'core.dart' as life_cycle;

typedef FuncWalletLockTime = int? Function();

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
  Timer _buildTimer(int t) {
    return Timer(Duration(seconds: t), _onTimer);
  }

  void _setupTimer(int? lockTime) {
    if (_timer != null || lockTime == null) return;
    if (lockTime == 0) return;
    _timer?.cancel();
    _timer = null;
    _timer = _buildTimer(lockTime);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
