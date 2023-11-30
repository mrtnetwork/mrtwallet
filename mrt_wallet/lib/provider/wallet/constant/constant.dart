class WalletProviderConst {
  static const int version = 1;
  static const int encryptionKeyLength = 32;
  static const int encryptionNonceLength = 12;
}

class WalletModelCborTagsConst {
  static const List<int> setting = [160];
  static const List<int> backup = [170];
  static const List<int> mnemonic = [180];
  static const List<int> walletCustomKey = [180, 0];
  static const List<int> iAccount = [200];
  static const List<int> address = [200, 80];
  static const List<int> accoutKeyIndex = [200, 81];
  static const List<int> importedAccountKeyIndex = [200, 82];
  static const List<int> multiSigAccountKeyIndex = [200, 83];
  static const List<int> bitcoinAccoint = [200, 192];
  static const List<int> bitcoinMultiSigAccount = [200, 192, 1];
  static const List<int> bitcoinMultiSignaturAddress = [200, 192, 1, 0];
  static const List<int> bitcoinMultiSigSignerAddress = [200, 192, 1, 0, 0];
}
