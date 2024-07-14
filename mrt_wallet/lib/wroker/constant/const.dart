class CryptoKeyConst {
  static const List<int> derivedKeys = [180, 1];
  static const List<int> accoutKeyIndex = [200, 81];
  static const List<int> multiSigAccountKeyIndex = [200, 83];
  static const List<int> walletCustomKey = [180, 0];
  static const List<int> substrateKeyIndex = [200, 84];

  static const List<int> setting = [160];
  static const List<int> mnemonic = [180];
  static const List<int> encryptedMasterKey = [180, 2];
  static const List<int> encryptedCustomKey = [180, 3];
  static const List<int> bip32KeyInfo = [180, 4];
  static const List<int> accessMnemonicResponse = [180, 5];
  static const List<int> accessPubliKeyResponse = [180, 6];
  static const List<int> accessPrivateKeyResponse = [180, 7];
  static const List<int> accessAdaLegacyPrivateKeyResponse = [180, 8];
  static const List<int> accessPrivateKeyRequest = [180, 9];
  static const List<int> accessPrivateKeysRequest = [180, 10];
  static const List<int> accessPublicKeyRequest = [180, 11];
  static const List<int> accessAdaPubliKeyResponse = [180, 12];
  static const List<int> accessPublicKeysRequest = [180, 13];
  static const List<int> importCustomKeys = [180, 14];

  static const List<int> globalSignature = [33, 1];

  static const List<int> bitconNetwork = [80, 0, 1];
  static const List<int> xrpNetwork = [80, 0, 2];
  static const List<int> evmNetwork = [80, 0, 3];
  static const List<int> tvmNetwork = [80, 0, 4];
  static const List<int> solanaNetwork = [80, 0, 5];
  static const List<int> cardanoNetwork = [80, 0, 6];
  static const List<int> cosmosNetwork = [80, 0, 7];
  static const List<int> bitcoinCashNetwork = [80, 0, 10];
  static const List<int> tonNetwork = [80, 0, 11];
  static const List<int> polkadotNetwork = [80, 0, 12];
  static const List<int> kusamaNetwork = [80, 0, 13];

  /// network tags
  static const List<int> generateToneMenemonic = [80, 1, 0];
  static const List<int> tonMnemonicToPrivateKey = [80, 1, 1];
}
// PublicKeyData
