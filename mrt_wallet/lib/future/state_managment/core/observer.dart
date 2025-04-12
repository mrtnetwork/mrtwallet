import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';

typedef OBSERVERLISTENER = void Function(Route route, Route? previousRoute);

class WalletRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final List<OBSERVERLISTENER> _pushListeners = [];
  final List<OBSERVERLISTENER> _popListeners = [];
  void addPushListener(OBSERVERLISTENER listener) {
    _pushListeners.add(listener);
  }

  void removePushListener(OBSERVERLISTENER listener) {
    _pushListeners.remove(listener);
  }

  void addPopListener(OBSERVERLISTENER listener) {
    _popListeners.add(listener);
  }

  void removePopListener(OBSERVERLISTENER listener) {
    _popListeners.remove(listener);
  }

  void _emitPushListeners(Route route, Route? previousRoute) {
    for (final i in [..._pushListeners]) {
      MethodUtils.nullOnException(() => i(route, previousRoute));
    }
  }

  void _emitPopListeners(Route route, Route? previousRoute) {
    for (final i in [..._popListeners]) {
      MethodUtils.nullOnException(() => i(route, previousRoute));
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _emitPushListeners(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _emitPopListeners(route, previousRoute);
  }
}
