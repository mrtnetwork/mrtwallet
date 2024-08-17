enum WalletAccsessType {
  seed,
  verify,
  unlock,
  extendedKey;

  bool get isAccsessKey => this == WalletAccsessType.extendedKey;
  bool get isAccessMnemonic => this == WalletAccsessType.seed;
  bool get isExtendedKey => this == WalletAccsessType.extendedKey;
  bool get isUnlock => this == WalletAccsessType.unlock;
}
