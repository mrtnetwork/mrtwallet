// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:mrt_wallet/types/typedef.dart';
import 'core.dart';

AppLifecycleListener platformLifeCycel(
        DynamicVoid onHide, DynamicVoid onFocus) =>
    WebLifeCycleListener(onHide: onHide, onFocus: onFocus);

class WebLifeCycleListener extends AppLifecycleListener {
  WebLifeCycleListener({required this.onFocus, required this.onHide});
  @override
  void dispose() {
    html.window.removeEventListener('focus', _onFocus);
    html.window.removeEventListener('blur', _onBlur);
  }

  @override
  void init() {
    html.window.addEventListener('focus', _onFocus);
    html.window.addEventListener('blur', _onBlur);
  }

  @override
  final DynamicVoid onFocus;

  @override
  final DynamicVoid onHide;

  void _onFocus(html.Event e) {
    onFocus();
  }

  void _onBlur(html.Event e) {
    onHide();
  }
}
