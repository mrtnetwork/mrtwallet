class WalletProviderConst {
  static const int version = 1;
  static const int encryptionKeyLength = 32;
  static const int encryptionNonceLength = 12;
}

class WalletModelCborTagsConst {
  static const List<int> appSetting = [44];
  static const List<int> setting = [160];
  static const List<int> backup = [170];
  static const List<int> backupV2 = [170, 2];
  static const List<int> mnemonic = [180];
  static const List<int> walletCustomKey = [180, 0];
  static const List<int> iAccount = [200];
  static const List<int> address = [200, 80];
  static const List<int> accoutKeyIndex = [200, 81];
  static const List<int> importedAccountKeyIndex = [200, 82];
  static const List<int> multiSigAccountKeyIndex = [200, 83];
  // bitcoin
  static const List<int> bitcoinCashAccount = [200, 191];
  static const List<int> bitcoinCashMultiSigAccount = [200, 191, 1];
  static const List<int> bitcoinAccount = [200, 192];
  static const List<int> bitcoinMultiSigAccount = [200, 192, 1];
  static const List<int> bitcoinMultiSignaturAddress = [200, 192, 1, 0];
  static const List<int> bitcoinMultiSigSignerAddress = [200, 192, 1, 0, 0];

  // xrp
  static const List<int> rippleAccount = [200, 193];
  static const List<int> rippleMultisigAccount = [200, 193, 1];
  static const List<int> rippleMultiSignaturAddress = [200, 193, 1, 0];
  static const List<int> rippleMultiSigSignerAddress = [200, 193, 1, 0, 0];
  // ethereum
  static const List<int> ethAccount = [200, 194];
// tron
  static const List<int> tronAccount = [200, 195];
  static const List<int> tronMultisigAccount = [200, 195, 1];
  static const List<int> tronMultiSignaturAddress = [200, 195, 1, 0];
  static const List<int> tronMultiSigSignerAddress = [200, 195, 1, 0, 0];
  static const List<int> tronAccountInfo = [200, 195, 100];
  static const List<int> tronAccountResource = [200, 195, 101];
  // contacts
  static const List<int> bitcoinContact = [100, 0];
  static const List<int> rippleContact = [100, 1];
  static const List<int> ethereumContact = [100, 2];
  static const List<int> tronContact = [100, 3];

  /// network tokens
  static const List<int> token = [110];
  static const List<int> rippleIssueToken = [110, 10];
  static const List<int> erc20Token = [110, 20];
  static const List<int> trc20Token = [110, 30];
  static const List<int> trc10Token = [110, 31];

  /// network nfts
  static const List<int> nft = [120];
  static const List<int> rippleNfts = [120, 10];

  static const List<int> networks = [0, 0, 0];
  static const List<int> network = [80];
  static const List<int> bitconNetwork = [80, 0, 1];
  static const List<int> xrpNetwork = [80, 0, 2];
  static const List<int> evmNetwork = [80, 0, 3];
  static const List<int> tvmNetwork = [80, 0, 4];
  static const List<int> bitcoinCashNetwork = [80, 0, 10];

  static const List<int> bitconNetworkParam = [80, 1, 1];
  static const List<int> xrpNetworkParam = [80, 1, 2];
  static const List<int> evmNetworkParam = [80, 1, 3];
  static const List<int> tvmNetworkParam = [80, 1, 4];

  ///
  static const List<int> apiServiceProvider = [90];
  static const List<int> electrumApiServiceProvider = [90, 0];
  static const List<int> tronApiServiceProvider = [90, 4];
  static const List<int> evmApiServiceProvider = [90, 3];
}
