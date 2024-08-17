part of 'package:mrt_wallet/future/state_managment/state_managment.dart';

mixin SafeState<T extends StatefulWidget> on State<T> {
  bool _closed = false;
  bool _builded = false;
  bool get closed => _closed;
  @override
  bool get mounted => !_closed && _builded && super.mounted;
  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void dispose() {
    _closed = true;
    super.dispose();
  }

  GlobalKey<NavigatorState>? navigatorKey;

  @override
  void didChangeDependencies() {
    navigatorKey ??= context.navigatorKey;
    _builded = true;
    super.didChangeDependencies();
  }

  void updateState([VoidCallback? fn]) {
    setState(fn ?? () {});
  }
}
