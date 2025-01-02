import 'package:blockchain_utils/utils/utils.dart';
import 'app_exception.dart';

class WalletException implements AppException {
  const WalletException.error(this.message) : _argruments = null;
  @override
  final String message;
  WalletException.invalidArgruments(List<String> this._argruments)
      : assert(_argruments.length == 2),
        message = "";
  const WalletException(this.message) : _argruments = null;
  final List<String>? _argruments;
  @override
  String toString() {
    if (_argruments != null) {
      return "invalid_request";
    }
    // if (_argruments != null) {
    //   return "invalid data excepted: ${_argruments[0]} got ${_argruments[1]}";
    // }
    return message;
  }

  @override
  bool operator ==(other) {
    if (other is! WalletException) return false;
    return other.message == message &&
        CompareUtils.iterableIsEqual(_argruments, other._argruments);
  }

  @override
  int get hashCode => Object.hash(message, _argruments);
}

class WalletExceptionConst {
  static const WalletException pubkeyRequired =
      WalletException("public_key_required_derive_address");
  static const WalletException dataVerificationFailed =
      WalletException("data_verification_failed");
  static WalletException invalidData({String? messsage}) =>
      const WalletException("data_verification_failed");
  static WalletException castingFailed({String? messsage}) =>
      const WalletException("data_casting_failed");
  static const WalletException invalidRequest =
      WalletException("invalid_request");
  static const WalletException invalidSerializationData =
      WalletException("invalid_serialization_data");
  static const WalletException invalidAccountDetails =
      WalletException("invalid_account_details");
  static const WalletException invalidBitcoinAddressType =
      WalletException("invalid_bitcoin_address_type");
  static const WalletException invalidMnemonicPassphrase =
      WalletException("invalid_passphrase");
  static const WalletException invalidMnemonic =
      WalletException("invalid_mnemonic");
  static const WalletException invalidBip39MnemonicWords =
      WalletException("invalid_bip39_mnemonic_words");
  static const WalletException invalidBackup =
      WalletException("invalid_wallet_backup");
  static const WalletException invalidBackupChecksum =
      WalletException("invalid_wallet_backup_checksum");

  ///
  static const WalletException incorrectPassword =
      WalletException("incorrect_password");
  static const WalletException passwordUsedBefore =
      WalletException("password_used_before");
  static const WalletException incorrectWalletData =
      WalletException("wallet_data_is_invalid");
  static const WalletException tooManyAccounts =
      WalletException("to_many_accounts");
  static const WalletException incorrectNetwork =
      WalletException("incorrect_network");
  static const WalletException invalidProviderInformation =
      WalletException("invalid_provider_infomarion");
  static const WalletException invalidBipKeyIndex =
      WalletException("invalid_bip_key_index");
  static const WalletException addressAlreadyExist =
      WalletException("address_already_exist");
  static const WalletException keyAlreadyExist =
      WalletException("key_already_exists");
  static const WalletException accountDoesNotFound =
      WalletException("account_not_found");
  static const WalletException notAuthorizedSigningAccount =
      WalletException("signing_auth_validator");
  static const WalletException signerAccountNotFound =
      WalletException("signer_account_does_not_exists");
  static const WalletException noActiveProvider =
      WalletException("no_acitve_provider");

  /// signer_account_does_not_exists
  static const WalletException incompleteWalletSetup =
      WalletException("incomplete_wallet_setup");
  static const WalletException walletDoesNotExists =
      WalletException("wallet_does_not_exists");
  static const WalletException privateKeyIsNotAvailable =
      WalletException("private_key_is_not_available");
  static const WalletException fileVerificationFiled =
      WalletException("file_verification_fail");
  static const WalletException toManyRequests =
      WalletException("to_many_request");
  static const WalletException rejectSigning =
      WalletException("user_rejected_signing_request");
  static const WalletException incorrectStatus =
      WalletException("incorrect_wallet_status");
  static const WalletException invalidContactDetails =
      WalletException("invalid_contact_details");
  static const WalletException contactExists =
      WalletException("contact_already_exist");
  static const WalletException invalidBalance =
      WalletException("invalid_balance");
  static const WalletException unsuportedFeature =
      WalletException("unsuported_feature");
  static const WalletException featureUnavailableForMultiSignature =
      WalletException("feature__unavailable_for_multi_signature");

  static const WalletException decryptionFailed =
      WalletException("decryption_failed");

  static const WalletException condition = WalletException("message");
  static const WalletException emptyThrow = WalletException("");

  static const WalletException invalidCoin = WalletException("invalid_coin");
  static const WalletException coinNotFound = WalletException("coin_not_found");

  static const WalletException invalidPrivateKey =
      WalletException("private_key_invalid");
  static const WalletException invalidExtendedKey =
      WalletException("extended_key_invalid");
  static const WalletException invalidWifKey =
      WalletException("wif_key_invalid");
  static const WalletException invalidRipplePrivateKeyAlgorithm =
      WalletException("invalid_ripple_privatekey_algorithm");
  static const WalletException multiSigDerivationNotSuported =
      WalletException("not_support_multisig_derivation");
  static const WalletException inaccessibleKeyAlgorithm =
      WalletException("inaccessible_key_algorithm");
  static const WalletException invalidTokenInformation =
      WalletException("invalid_token_information");
  static const WalletException invalidNftInfromaation =
      WalletException("invalid_nft_information");
  static WalletException invalidArgruments(String expected, String got) {
    return WalletException.invalidArgruments([expected, got]);
  }

  static const WalletException walletIsLocked =
      WalletException("wallet_is_locked");
  static const WalletException networkTokenUnsuported =
      WalletException("network_support_token_error");
  static const WalletException networkNFTsUnsuported =
      WalletException("network_support_nft_error");
  static const WalletException tokenAlreadyExist =
      WalletException("token_already_exists");
  static const WalletException nftsAlreadyExist =
      WalletException("nfts_already_exists");

  static const WalletException walletAlreadyExists =
      WalletException("wallet_already_exists");
  static const WalletException walletNameExists =
      WalletException("wallet_name_exists");
  static const WalletException pageClosed = WalletException("page_closed");
  static const WalletException walletIsNotavailable =
      WalletException("wallet_is_not_available");

  static const WalletException ethSubscribe =
      WalletException("eth_subscribe_websocket_requirment");
  static const WalletException networkDoesNotExist =
      WalletException("network_does_not_exist");
}
