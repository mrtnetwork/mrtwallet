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
  static const List<int> stellar = [80, 0, 14];

  /// network tags
  static const List<int> generateToneMenemonic = [111, 1];
  static const List<int> tonMnemonicToPrivateKey = [111, 2];

  static const List<int> ethereumPersonalSign = [111, 3];
  static const List<int> ethereumTypedDataSign = [111, 4];
  static const List<int> deriveAddress = [111, 5];

  static const List<int> encryptChacha = [111, 10];
  static const List<int> decryptChacha = [111, 12];

  static const List<int> generateMasterKey = [111, 20];
  static const List<int> readEncryptedMasterKey = [111, 21];
  static const List<int> createMasterKey = [111, 22];
  static const List<int> createWallet = [111, 23];
  static const List<int> restoreBackup = [111, 24];
  static const List<int> readPublicKeys = [111, 25];
  static const List<int> readPrivateKeys = [111, 26];
  static const List<int> readMnemonic = [111, 27];
  static const List<int> updateWalletKeys = [111, 28];
  static const List<int> removeWalletKeys = [111, 29];
  static const List<int> sign = [111, 30];
  static const List<int> decodeBackup = [111, 31];
  static const List<int> encodeBackup = [111, 32];
  static const List<int> readImportKey = [111, 33];
  static const List<int> generateBip39Mnemonic = [111, 34];
  static const List<int> walletKey = [111, 35];
  static const List<int> randomGenerator = [111, 36];
  static const List<int> hexToBytes = [111, 37];
  static const List<int> hashing = [111, 38];
  static const List<int> walletBackup = [111, 40];
  static const List<int> setupMasterKey = [111, 41];

  static const List<int> restoreBackModel = [112, 0];
}
// PublicKeyData
