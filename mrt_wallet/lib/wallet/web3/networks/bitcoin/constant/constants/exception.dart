import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3BitcoinExceptionConstant {
  static Web3RequestException get invalidTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid account or transaction. The parameters must contain both 'accounts' and 'psbt' as base64-encoded.");

  static Web3RequestException get invalidSendTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid accounts or transaction. The parameters must contain both 'accounts' and at least one 'outputs'.");
  static Web3RequestException get invalidPSBT =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid PSBT. Missing required inputs or outputs.");
  static Web3RequestException get invalidTransactionAccount =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid accounts: All accounts must belong to the same network.");

  static Web3RequestException get noRelatedInput =>
      Web3RequestExceptionConst.message("No related inputs found for signing.");
  static Web3RequestException txInputNotFound(String txId, int index) =>
      Web3RequestExceptionConst.invalidParameters(
          "Transaction input with TXID $txId and index $index not found in the list of unspent inputs.");
  static Web3RequestException parsingScriptFailed(String name, String data) =>
      Web3RequestExceptionConst.message(
          "Parsing script $name failed. Please ensure it is a valid Bitcoin script serialized as hex.",
          data: data);

  static Web3RequestException parsingOutputScriptFailed(String data) =>
      Web3RequestExceptionConst.message(
          "Failed to parse output script. Please ensure it is a valid Bitcoin script serialized as hex.",
          data: data);

  static Web3RequestException invalidAddress(String address, String network) =>
      Web3RequestExceptionConst.message("Failed to parse $network address.",
          data: address);

  static Web3RequestException get emptyOutput =>
      Web3RequestExceptionConst.invalidParameters(
          "At least one output required for create transaction.");
  static Web3RequestException get invalidOutput =>
      Web3RequestExceptionConst.invalidParameters(
          "Output object must contain either an address or a script, but not both. Value must be an integer represented as a string.");
  static Web3RequestException invalidSignMessageAccount(String address) =>
      Web3RequestExceptionConst.message(
          "The account $address does not support message signing. Only P2PKH, P2WPKH, and P2WPKH-P2SH addresses are allowed to sign messages.");
}
