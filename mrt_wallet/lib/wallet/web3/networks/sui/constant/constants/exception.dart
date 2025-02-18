import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3SuiExceptionConstant {
  static Web3RequestException get invalidTransaction =>
      Web3RequestExceptionConst.invalidParameters("Invalid Sui transaction");
  static Web3RequestException get invalidSuiSigningMessage =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid Sui signing message. Must include 'account', and 'message' fields and message must be a valid Uint8Array.");

  static Web3RequestException get singTransactionInsteadMessage =>
      Web3RequestExceptionConst.invalidParameters(
          "for signing a transaction using the `sui_signTransaction` method.");
  static Web3RequestException get invalidSwitchChain =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid Sui switch chain params. params must include 'chainId', and 'name' fields");
  static Web3RequestException invalidTransactionNetwork(
          {required String currentChain, required String requestChain}) =>
      Web3RequestExceptionConst.invalidParameters(
          "Chain mismatch: Transaction requested for $requestChain, but the wallet is connected to $currentChain");
  static const Web3RequestException suiNetworkDoesNotExist =
      Web3RequestException(
          message: "Invalid method parameters.",
          data: "The specified sui network does not exist.",
          walletCode: "WEB3-5080",
          code: -32600);

  static Web3RequestException failedToResolveObject(String objectId) =>
      Web3RequestExceptionConst.invalidParameters(
          "Unable to resolve object $objectId");
  static Web3RequestException failedToResolvePureArgs() =>
      Web3RequestExceptionConst.invalidParameters(
          "Unable to resolve pure value");
  static final Web3RequestException invalidBase64Pure =
      Web3RequestExceptionConst.invalidParameters(
          "Invalid pure value: Failed to decode Base64 to bytes.");
  static Web3RequestException invalidObject(String objectId) =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid object: Unable to resolve object $objectId");
  static Web3RequestException retrieveObjectFailed(String? msg) =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid object: Failed to retrieve the object.${msg != null ? ' Error message: $msg.' : ''}");
  static final Web3RequestException mismatchMoveCallArguments =
      Web3RequestExceptionConst.invalidParameters(
          "Invalid Move call arguments. Mismatch in parameter and argument lengths.");
  static Web3RequestException invalidObjectId(String objectId) =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid object id: Expected an object, but received a $objectId");
  static Web3RequestException invalidCommandParameters(String command) =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid object id: Expected an object, failed to parse command object $command");
  static final Web3RequestException parsingTransactionFailed =
      Web3RequestExceptionConst.invalidParameters(
          "Parsing transaction failed.");

  static Web3RequestException get unsuportedTransactionVersion =>
      Web3RequestExceptionConst.unsuportedfeatures(
          "Unknow transaction version");
}
