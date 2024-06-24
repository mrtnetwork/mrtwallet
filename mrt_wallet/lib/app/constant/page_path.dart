import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';

class PagePathConst {
  const PagePathConst._();

  /// bitcoin casah
  static const String bitcoinCashTransaction = "/bitcoincash/transaction";

  static const String bitcoinTransaction = "/bitcoin/transaction";
  static const String rippleTransfer = "/ripple/transfer";
  static const String rippleAddToken = "/ripple/import_token";
  static const String rippleAddNfts = "/ripple/import_nfts";
  static const String rippleTransaction = "/ripple/transaction";
  static const String rippleMultisigAddress = "/ripple/setup_multisig_address";
  static const String rippleSettingPage = "setting/ripple";
  static const String rippleKeyConversion = "setting/ripple/key_conversion";

  static const String ethereumTransaction = "/ethereum/transfer";

  // tron
  static const String tronTransfer = "/tron/transfer";
  static const String tronTransaction = "/tron/transaction";
  static const String tronMultiSigAddress = "/tron/setup_multisig_address";
  // solana transfer
  static const String solanaTransfer = "/solana/transfer";
  static const String solanaTransaction = "/solana/transaction";

  // ton transfer
  static const String tonTransfer = "/ton/transfer";

  /// cardano
  static const String cardanoTransaction = "/cardano/transaction";
  static const String cosmosTransaction = "/cosmos/transaction";

  // static const String setupRippleAddress = "/ripple/setup_address";
  static const String setupBitcoinAddress = "/bitcoin/setup_address";
  static const String setupGenericAddress = "/networks/setup_address";
  static const String setupCardanoAddress = "/cardano/setup_address";

  static const String setupBitcoinMultsig = "/bitcoin/setup_multisig_address";

  static const String setup = "/setup";
  static const String home = "/";

  static const String setting = "/setting";
  static const String updateSetting = "/setting/update";

  /// acccount
  static const String removeAccount = "/account/remove";
  static const String importAccount = "/account/import";

  /// security
  static const String changePassword = "/security/password";
  static const String eraswWallet = "/security/erase";
  static const String backupWallet = "/security/backup";
  static const String exportPrivateKey = "/security/privateKey";
  static const String manageImportedKey = "/security/manageKeys";
  static const String exportSeed = "/security/seed";

  /// importnetworks
  static const String importEVMNetwork = "/networks/import";
  static const String editEvmNetwork = "/networks/edit";
  static const String updateElectrumProviders = "/networks/bitcoin/providers";
  static const String editSolanaNetwork = "/networks/solana/providers";
  static String providerDetails(AppNetworkImpl network) {
    switch (network.type) {
      case NetworkType.ethereum:
        return editEvmNetwork;
      case NetworkType.solana:
        return editSolanaNetwork;
      default:
        return updateElectrumProviders;
    }
  }

  static String transactionPage(AppNetworkImpl network) {
    switch (network.type) {
      case NetworkType.bitcoinAndForked:
        return bitcoinTransaction;
      case NetworkType.ethereum:
        return ethereumTransaction;
      case NetworkType.tron:
        return tronTransfer;
      case NetworkType.solana:
        return solanaTransfer;
      case NetworkType.ton:
        return tonTransfer;
      case NetworkType.cardano:
        return cardanoTransaction;
      case NetworkType.cosmos:
        return cosmosTransaction;
      default:
        return rippleTransfer;
    }
  }

  static String setupAddressPage(AppNetworkImpl network) {
    switch (network.type) {
      case NetworkType.bitcoinAndForked:
        return setupBitcoinAddress;
      case NetworkType.cardano:
        return setupCardanoAddress;
      default:
        return setupGenericAddress;
    }
  }

  static String? networkSettings(AppNetworkImpl network) {
    switch (network.type) {
      case NetworkType.ton:
        return tonSettings;
      case NetworkType.xrpl:
        return rippleSettingPage;
      default:
        return null;
    }
  }

  static const String importERC20Token = "ethereum/import_token";
  static const String importTRC20Token = "tron/import_token";
  static const String importTrc10Token = "tron/import_trc10_token";
  static const String importSPLTokens = "solana/import_spl_tokens";

  static const String tonSettings = "setting/ton";
  static const String tonMnemonic = "setting/ton/mnemonic";
  static const String importJettons = "ton/import_jettons";
}
