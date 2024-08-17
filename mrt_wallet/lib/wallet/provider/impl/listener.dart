part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

typedef OnWalletEvent = void Function(WalletEventStaus);

mixin WalletsListener on WalletsManager {
  final Set<OnWalletEvent> _listeners = {};
  final Set<DynamicVoid> _onChainChanged = {};
  @override
  void addOnChainChangedListener(DynamicVoid listener) {
    _onChainChanged.add(listener);
  }

  @override
  void removeOnChainChangedListener(DynamicVoid listener) {
    _onChainChanged.remove(listener);
  }

  @override
  void addWalletStatusListener(OnWalletEvent listener) {
    _listeners.add(listener);
    _emitListener(listener);
    _wallet?._timeout.init();
  }

  @override
  void removeWalletStatusListener(OnWalletEvent listener) {
    _listeners.remove(listener);
  }

  void _emitWalletListeners() {
    final listeners = [..._listeners];
    for (final i in listeners) {
      _emitListener(i);
    }
  }

  void _emitOnChainChangedListener() {
    final listeners = [..._onChainChanged];
    for (final i in listeners) {
      MethodUtils.nullOnException(i);
    }
  }

  void _emitListener(OnWalletEvent listener) {
    MethodUtils.nullOnException(
        () => listener(WalletEventStaus.fromWalletStatus(_wallet?._status)));
  }
}
