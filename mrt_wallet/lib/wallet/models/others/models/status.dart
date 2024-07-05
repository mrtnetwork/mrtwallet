// enum WalletStatus { lock, unlock, setup }

enum HDWalletStatus {
  readOnly(true),
  lock(false),
  unlock(true);

  final bool isOpen;
  const HDWalletStatus(this.isOpen);
}

enum WalletStatus {
  setup,
  ready;

  bool get isReady => this == WalletStatus.ready;
}

enum WalletEventStaus {
  setup,
  lock,
  unlock;

  bool get isReady => this != WalletEventStaus.setup;
  static WalletEventStaus fromWalletStatus(WalletStatus status, bool isOpen) {
    if (isOpen) return WalletEventStaus.unlock;
    if (status.isReady) return WalletEventStaus.lock;
    return WalletEventStaus.setup;
  }

  bool get isOpen => this == WalletEventStaus.unlock;
}
