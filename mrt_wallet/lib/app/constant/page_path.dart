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

  static const String ethereumTransaction = "/ethereum/transfer";

  // tron
  static const String tronTransfer = "/tron/transfer";
  static const String tronTransaction = "/tron/transaction";
  static const String tronMultiSigAddress = "/tron/setup_multisig_address";
  // solana transfer
  static const String solanaTransfer = "/solana/transfer";

  /// cardano
  static const String cardanoTransaction = "/cardano/transaction";
  static const String cosmosTransaction = "/cosmos/transaction";

  static const String setupRippleAddress = "/ripple/setup_address";
  static const String setupBitcoinAddress = "/bitcoin/setup_address";
  static const String setupEthAddress = "/ethereum/setup_address";
  static const String setupTronAddress = "/tron/setup_address";
  static const String setupSolanaAddress = "/solana/setup_address";
  static const String setupCardanoAddress = "/cardano/setup_address";
  static const String setupCosmosAddress = "/cosmos/setup_address";

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

  static String providerDetails(AppNetworkImpl network) {
    if (network is APPEVMNetwork) return editEvmNetwork;
    return updateElectrumProviders;
  }

  static String transactionPage(AppNetworkImpl network) {
    if (network is AppBitcoinNetwork) return bitcoinTransaction;
    if (network is APPEVMNetwork) return ethereumTransaction;
    if (network is APPTVMNetwork) return tronTransfer;
    if (network is APPSolanaNetwork) return solanaTransfer;
    if (network is APPCardanoNetwork) return cardanoTransaction;
    if (network is APPCosmosNetwork) return cosmosTransaction;
    return rippleTransfer;
  }

  static String setupAddressPage(AppNetworkImpl network) {
    if (network is AppBitcoinNetwork) return setupBitcoinAddress;
    if (network is APPEVMNetwork) return setupEthAddress;
    if (network is APPTVMNetwork) return setupTronAddress;
    if (network is APPSolanaNetwork) return setupSolanaAddress;
    if (network is APPCardanoNetwork) return setupCardanoAddress;
    if (network is APPCosmosNetwork) return setupCosmosAddress;
    return setupRippleAddress;
  }

  static const String importERC20Token = "ethereum/import_token";
  static const String importTRC20Token = "tron/import_token";
  static const String importTrc10Token = "tron/import_trc10_token";

  static const String importSPLTokens = "solana/import_spl_tokens";
}
