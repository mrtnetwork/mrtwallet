import 'dart:async';
import 'package:mrt_wallet/app/core.dart';

typedef FuncWalletLockTime = int? Function();

class WalletTimeoutListener {
  WalletTimeoutListener(this._onTimer, this._onLockTime);
  final _lock = SynchronizedLock();

  void init() {
    _lock.synchronized(() {
      final int? locktime = _onLockTime();
      if (locktime == null) {
        return null;
      }
      if (locktime <= 0) {
        _onLockTime();
        return;
      }
      _setupTimer(locktime);
    });
  }

  void dispose() {
    _lock.synchronized(() {
      _stopTimer();
    });
  }

  StreamSubscription<int>? _timer;
  final DynamicVoid _onTimer;
  final FuncWalletLockTime _onLockTime;
  int _tick = 0;

  int? get remining {
    if (_tick <= 0) return null;
    return _tick;
  }

  void _onListenTimer(int tick) {
    _tick--;
  }

  StreamSubscription<int> _buildTimer(int t) {
    // final int tick = t ~/ _WalletTimeoutListener.prediocTime;
    return Stream<int>.periodic(
      Duration(seconds: 1),
      (computationCount) => computationCount,
    ).take(t).listen(_onListenTimer, onDone: _onTimer);
  }

  void _setupTimer(int lockTime) {
    _stopTimer();
    _tick = lockTime;
    _timer = _buildTimer(lockTime);
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _tick = 0;
  }
}
