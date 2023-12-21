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
  // bitcoin
  static const List<int> bitcoinAccoint = [200, 192];
  static const List<int> bitcoinMultiSigAccount = [200, 192, 1];
  static const List<int> bitcoinMultiSignaturAddress = [200, 192, 1, 0];
  static const List<int> bitcoinMultiSigSignerAddress = [200, 192, 1, 0, 0];

  // xrp
  static const List<int> rippleAccount = [200, 193];
  static const List<int> rippleMultisigAccount = [200, 193, 1];
  static const List<int> rippleMultiSignaturAddress = [200, 193, 1, 0];
  static const List<int> rippleMultiSigSignerAddress = [200, 193, 1, 0, 0];

  // contacts
  static const List<int> bitcoinContact = [100, 0];
  static const List<int> rippleContact = [100, 1];

  /// network tokens
  static const List<int> token = [110];
  static const List<int> rippleIssueToken = [110, 10];

  /// network nfts
  static const List<int> nft = [120];
  static const List<int> rippleNfts = [120, 10];
}
