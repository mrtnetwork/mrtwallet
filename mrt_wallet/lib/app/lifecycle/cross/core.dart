import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'cross.dart'
    if (dart.library.html) 'web.dart'
    if (dart.library.io) 'android.dart';

abstract class AppLifecycleListener {
  abstract final DynamicVoid onHide;
  abstract final DynamicVoid onFocus;
  void init();
  void dispose();
  static AppLifecycleListener instance(
      DynamicVoid onHide, DynamicVoid onFocus) {
    return platformLifeCycel(onHide, onFocus);
  }
}
