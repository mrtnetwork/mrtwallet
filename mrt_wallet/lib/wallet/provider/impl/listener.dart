part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

typedef OnWalletEvent = void Function(WalletEventStaus);
mixin WalletListener on WalletManager {
  final Set<OnWalletEvent> _listeners = {};

  @override
  void addWalletListener(OnWalletEvent listener) {
    _listeners.add(listener);
    _emitListener(listener);
  }

  @override
  void removeWalletListener(OnWalletEvent listener) {
    _listeners.remove(listener);
  }

  void emitWalletListeners() {
    final listeners = [..._listeners];
    final status = WalletEventStaus.fromWalletStatus(_homePageStatus, isOpen);
    for (final i in listeners) {
      MethodUtils.nullOnException(() => i(status));
    }
  }

  void _emitListener(OnWalletEvent listener) {
    MethodUtils.nullOnException(() =>
        listener(WalletEventStaus.fromWalletStatus(_homePageStatus, isOpen)));
  }
}
