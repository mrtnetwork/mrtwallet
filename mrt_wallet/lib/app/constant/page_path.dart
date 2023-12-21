import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';

class PagePathConst {
  const PagePathConst._();

  static const String bitcoinTransaction = "/bitcoin/transaction";
  static const String rippleTransfer = "/ripple/transfer";
  static const String rippleAddToken = "/ripple/import_token";
  static const String rippleAddNfts = "/ripple/import_nfts";
  static const String rippleTransaction = "/ripple/transaction";
  static const String rippleMultisigAddress = "/ripple/setup_multisig_address";

  static const String setupRippleAddress = "/ripple/setup_address";
  static const String setupBitcoinAddress = "/bitcoin/setup_address";

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

  static String transactionPage(AppNetworkImpl networkImpl) {
    if (networkImpl is AppBitcoinNetwork) return bitcoinTransaction;
    return rippleTransfer;
  }

  static String setupAddressPage(AppNetworkImpl networkImpl) {
    if (networkImpl is AppBitcoinNetwork) return setupBitcoinAddress;
    return setupRippleAddress;
  }
}
