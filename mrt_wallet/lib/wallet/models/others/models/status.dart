enum HDWalletStatus {
  readOnly(true),
  lock(false),
  unlock(true);

  final bool isOpen;
  const HDWalletStatus(this.isOpen);
  bool get isUnlock => this == HDWalletStatus.unlock;
}

enum WalletStatus {
  setup,
  ready;

  bool get isReady => this == WalletStatus.ready;
  bool get isSetup => this == WalletStatus.setup;
}

enum WalletEventStaus {
  setup,
  lock,
  readOnly,
  unlock;

  bool get isReady => this != WalletEventStaus.setup;
  static WalletEventStaus fromWalletStatus(HDWalletStatus? walletStatus) {
    switch (walletStatus) {
      case HDWalletStatus.lock:
        return WalletEventStaus.lock;
      case HDWalletStatus.unlock:
        return WalletEventStaus.unlock;
      case HDWalletStatus.readOnly:
        return WalletEventStaus.readOnly;
      default:
        return WalletEventStaus.setup;
    }
  }

  bool get isOpen =>
      this == WalletEventStaus.unlock || this == WalletEventStaus.readOnly;
}
