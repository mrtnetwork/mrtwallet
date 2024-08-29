import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3TronExceptionConstant {
  static const String trc10TokenNotFound =
      "The TRC10 token ID you provided does not exist.";
  static Web3RequestException get invalidTransactionParams =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid transaction JSON. Parsing unsuccessful.");

  static Web3RequestException get invalidTransactionTxId =>
      Web3RequestExceptionConst.invalidParameters(
          "Mismatch in transaction ID: The serialized transaction produced a different ID than the one provided.");
  static Web3RequestException get accountNotFoundOrNotActivated =>
      Web3RequestExceptionConst.failedRequest(
          "the provided account does not active.");
  static Web3RequestException get invalidTransactionPermissionId =>
      Web3RequestExceptionConst.failedRequest(
          "Invalid transaction. Transaction permission does not exists.");
  static Web3RequestException get invalidSignedMessageV2Parameters =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid transaction. signed message only accepts bytes or string.");
}
