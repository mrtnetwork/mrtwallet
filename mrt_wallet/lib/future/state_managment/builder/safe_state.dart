part of 'package:mrt_wallet/future/state_managment/state_managment.dart';

mixin SafeState<T extends StatefulWidget> on State<T> {
  bool _closed = false;
  bool _builded = false;
  bool get closed => _closed;
  @override
  bool get mounted => !_closed && _builded && super.mounted;

  void onInitOnce() {}

  void safeDispose() {}

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void dispose() {
    _closed = true;
    try {
      safeDispose();
    } catch (_) {}
    super.dispose();
  }

  GlobalKey<NavigatorState>? navigatorKey;

  @override
  void didChangeDependencies() {
    navigatorKey ??= context.navigatorKey;
    if (!_builded) onInitOnce();
    _builded = true;
    super.didChangeDependencies();
  }

  void updateState([VoidCallback? fn]) {
    setState(fn ?? () {});
  }
}

mixin ProgressMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<PageProgressState> progressKey = GlobalKey();
}
