import 'package:blockchain_utils/utils/utils.dart';
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
    if (_argruments != null) {
      return "invalid_request";
    }
    if (_argruments != null) {
      return "invalid data excepted: ${_argruments[0]} got ${_argruments[1]}";
    }
    return message;
  }

  @override
  operator ==(other) {
    if (other is! WalletException) return false;
    return other.message == message &&
        CompareUtils.iterableIsEqual(_argruments, other._argruments);
  }

  @override
  int get hashCode => Object.hash(message, _argruments);
}

class WalletExceptionConst {
  static final WalletException dataVerificationFailed =
      WalletException("data_verification_failed");
  static final WalletException invalidRequest =
      WalletException("invalid_request");
  static final WalletException invalidSerializationData =
      WalletException("invalid_serialization_data");
  static final WalletException invalidAccountDetails =
      WalletException("invalid_account_details");
  static final WalletException invalidBitcoinAddressType =
      WalletException("invalid_bitcoin_address_type");
  static final WalletException invalidMnemonicPassphrase =
      WalletException("invalid_passphrase");
  static final WalletException invalidMnemonic =
      WalletException("invalid_mnemonic");
  static final WalletException invalidBip39MnemonicWords =
      WalletException("invalid_bip39_mnemonic_words");
  static final WalletException invalidBackup =
      WalletException("invalid_wallet_backup");
  static final WalletException invalidBackupChecksum =
      WalletException("invalid_wallet_backup_checksum");

  ///
  static final WalletException incorrectPassword =
      WalletException("incorrect_password");
  static final WalletException passwordUsedBefore =
      WalletException("password_used_before");
  static final WalletException incorrectWalletData =
      WalletException("wallet_data_is_invalid");
  static final WalletException tooManyAccounts =
      WalletException("to_many_accounts");
  static final WalletException incorrectNetwork =
      WalletException("incorrect_network");
  static final WalletException invalidProviderInformation =
      WalletException("invalid_provider_infomarion");
  static final WalletException invalidBipKeyIndex =
      WalletException("invalid_bip_key_index");
  static final WalletException addressAlreadyExist =
      WalletException("address_already_exist");
  static final WalletException keyAlreadyExist =
      WalletException("key_already_exists");
  static final WalletException accountDoesNotFound =
      WalletException("account_not_found");
  static final WalletException notAuthorizedSigningAccount =
      WalletException("signing_auth_validator");
  static final WalletException incompleteWalletSetup =
      WalletException("incomplete_wallet_setup");
  static final WalletException walletDoesNotExists =
      WalletException("wallet_does_not_exists");
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

  static final WalletException decryptionFailed =
      WalletException("decryption_failed");

  static final WalletException condition = WalletException("message");
  static final WalletException emptyThrow = WalletException("");

  static final WalletException invalidCoin = WalletException("invalid_coin");
  static final WalletException coinNotFound = WalletException("coin_not_found");

  static final WalletException invalidPrivateKey =
      WalletException("private_key_invalid");
  static final WalletException invalidExtendedKey =
      WalletException("extended_key_invalid");
  static final WalletException invalidWifKey =
      WalletException("wif_key_invalid");
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

  static final WalletException walletAlreadyExists =
      WalletException("wallet_already_exists");
  static final WalletException walletNameExists =
      WalletException("wallet_name_exists");
  static final WalletException pageClosed = WalletException("page_closed");
  static final WalletException walletIsNotavailable =
      WalletException("wallet_is_not_available");

  static final WalletException ethSubscribe =
      WalletException("eth_subscribe_websocket_requirment");
  static final WalletException networkDoesNotExist =
      WalletException("network_does_not_exist");
}
