import 'package:flutter/foundation.dart';
import 'app_exception.dart';

class WalletException implements AppException {
  @override
  final String message;
  WalletException.invalidArgruments(List<String> this._argruments)
      : assert(_argruments.length == 2),
        message = "";
  WalletException(this.message) : _argruments = null;
  final List<String>? _argruments;
  @override
  String toString() {
    if (_argruments != null && !kDebugMode) {
      return "invalid_request";
    }
    if (_argruments != null) {
      return "invalid data excepted ${_argruments![0]} got ${_argruments![1]}";
    }
    return message;
  }
}

class WalletExceptionConst {
  static final WalletException invalidAccountDetails =
      WalletException("invalid_account_details");
  static final WalletException invalidBitcoinAddressType =
      WalletException("invalid_bitcoin_address_type");
  static final WalletException invalidMnemonicPassphrase =
      WalletException("invalid_passphrase");
  static final WalletException invalidMnemonic =
      WalletException("invalid_mnemonic");
  static final WalletException invalidBackup =
      WalletException("invalid_wallet_backup");
  static final WalletException incorrectPassword =
      WalletException("incorrect_password");
  static final WalletException incorrectWalletData =
      WalletException("wallet_data_is_invalid");
  static final WalletException tooManyAccounts =
      WalletException("to_many_accounts");
  static final WalletException incorrectNetwork =
      WalletException("incorrect_network");
  static final WalletException invalidBipKeyIndex =
      WalletException("invalid_bip_key_index");
  static final WalletException addressAlreadyExist =
      WalletException("address_already_exist");
  static final WalletException keyAlreadyExist =
      WalletException("key_already_exists");
  static final WalletException accountDoesNotFound =
      WalletException("account_not_found");
  static final WalletException privateKeyIsNotAvailable =
      WalletException("private_key_is_not_available");
  static final WalletException fileVerificationFiled =
      WalletException("file_verification_fail");
  static final WalletException toManyRequests =
      WalletException("to_many_request");
  static final WalletException rejectSigning =
      WalletException("user_rejected_signing_request");
  static final WalletException incorrectStatus =
      WalletException("incorrect_wallet_status");
  static final WalletException invalidContactDetails =
      WalletException("invalid_contact_details");
  static final WalletException contactExists =
      WalletException("contact_already_exist");
  static final WalletException invalidBalance =
      WalletException("invalid_balance");
  static final WalletException unsuportedFeature =
      WalletException("unsuported_feature");
  static final WalletException featureUnavailableForMultiSignature =
      WalletException("feature__unavailable_for_multi_signature");

  static final WalletException condition = WalletException("message");
  static final WalletException emptyThrow = WalletException("");

  static final WalletException invalidCoin = WalletException("invalid_coin");

  static final WalletException invalidPrivateKey =
      WalletException("private_key_invalid");
  static final WalletException invalidRipplePrivateKeyAlgorithm =
      WalletException("invalid_ripple_privatekey_algorithm");
  static final WalletException multiSigDerivationNotSuported =
      WalletException("not_support_multisig_derivation");
  static final WalletException inaccessibleKeyAlgorithm =
      WalletException("inaccessible_key_algorithm");
  static final WalletException invalidTokenInformation =
      WalletException("invalid_token_information");
  static final WalletException invalidNftInfromaation =
      WalletException("invalid_nft_information");
  static WalletException invalidArgruments(String expected, String got) {
    return WalletException.invalidArgruments([expected, got]);
  }

  static final WalletException walletIsLocked =
      WalletException("wallet_is_locked");
  static final WalletException networkTokenUnsuported =
      WalletException("network_support_token_error");
  static final WalletException networkNFTsUnsuported =
      WalletException("network_support_nft_error");
  static final WalletException tokenAlreadyExist =
      WalletException("token_already_exists");
  static final WalletException nftsAlreadyExist =
      WalletException("nfts_already_exists");
}
