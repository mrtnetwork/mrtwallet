import 'package:blockchain_utils/exception/exceptions.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_wallet/app/error/exception/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3RequestExceptionConst {
  static const String requestTimeoutMessage = "Request timeout";
  static const String invalidTransactionTypeMessage =
      "Invalid Transaction type.";
  static const String invalidTransactionTypeOrGas =
      "The provided transaction type does not correspond with the specified gas parameters.";
  static const String invalidTransactionAccessList =
      "The provided transaction type does not support Ethereum transaction accessList parameters.";
  static const String eip1559NotSupported =
      "The current network does not support EIP-1559 transactions.";

  static Web3RequestException fromException(Object exception) {
    if (exception is Web3RequestException) return exception;
    if (exception is RPCError) {
      return Web3RequestException(
          message: exception.message,
          code: exception.errorCode ?? -1,
          walletCode: "WALLET-001",
          data: StringUtils.tryFromJson(exception.details));
    } else if (exception is ApiProviderException) {
      return Web3RequestException(
          message: exception.message ?? "The Provider is disconnected.",
          code: 4901,
          walletCode: "WALLET-001",
          data: exception.isTimeout
              ? requestTimeoutMessage
              : exception.toString());
    }
    return internalError;
  }

  static const Web3RequestException internalError = Web3RequestException(
      message: "An error occurred during the request",
      walletCode: "WALLET-000",
      code: -32603);
  static const Web3RequestException rejectedByUser = Web3RequestException(
    message: "The user rejected the request.",
    walletCode: "WALLET-3000",
    code: 4001,
  );
  static const Web3RequestException invalidRequest = Web3RequestException(
      message: "The request is not a valid Request object.",
      walletCode: "WALLET-4050",
      code: -32000);

  static const Web3RequestException invalidNetwork = Web3RequestException(
      message: "The specified network is invalid or does not exist.",
      walletCode: "WALLET-4000",
      code: -32000);

  static const Web3RequestException missingPermission = Web3RequestException(
      message:
          "The requested method and/or account has not been authorized by the user.",
      data:
          "The Web3 application does not have the required permissions. Please send a permission request first.",
      walletCode: "WEB3-4010",
      code: 4100);
  static const Web3RequestException methodDoesNotExist = Web3RequestException(
      message:
          "The requested method does not exist. Please check the method name and try again.",
      walletCode: "WEB3-4030",
      code: 4200);

  static const Web3RequestException methodDoesNotSupport = Web3RequestException(
      message: "The requested method does not supported.",
      walletCode: "WEB3-4030",
      code: 4200);

  static const Web3RequestException disconnectedChain = Web3RequestException(
      message: "The Provider is not connected to the requested chain.",
      walletCode: "WEB3-6000",
      code: 4901);

  static const Web3RequestException invalidHost = Web3RequestException(
      message:
          "Invalid host: Ensure that the request comes from a valid host and try again.",
      walletCode: "WEB3-4020",
      code: -1);
  static const Web3RequestException walletNotInitialized = Web3RequestException(
      message: "Wallet not initialized.", walletCode: "WEB3-5020", code: -1);

  static const Web3RequestException bannedHost = Web3RequestException(
      message:
          "The requested method and/or account has not been authorized by the user.",
      data:
          "The URL is disable by the owner of the wallet. Please use an allowed URL or contact the wallet owner for further assistance.",
      walletCode: "WEB3-4040",
      code: 4100);

  static Web3RequestException invalidStringArgrument(String parameterName) =>
      Web3RequestException(
          message:
              "Invalid method parameters. Invalid string argument provided for $parameterName.",
          walletCode: "WEB3-0020",
          code: -32602);
  static Web3RequestException invalidBoolean(String parameterName) =>
      Web3RequestException(
          message:
              "Invalid method parameters. Invalid boolean argument provided for $parameterName.",
          walletCode: "WEB3-0020",
          code: -32602);

  static Web3RequestException invalidAddressArgrument(String addressType) =>
      Web3RequestException(
          message:
              "Invalid method parameters. Invalid address argument provided for $addressType.",
          walletCode: "WEB3-0030",
          code: -32602);

  static Web3RequestException invalidHexBytes(String parameterName) =>
      Web3RequestException(
          message:
              "Invalid method parameters. Invalid hex string for $parameterName.",
          walletCode: "WEB3-0040",
          code: -32602);
  static Web3RequestException invalidBase64Bytes(String parameterName) =>
      Web3RequestException(
          message:
              "Invalid method parameters. Invalid base64 string for $parameterName.",
          walletCode: "WEB3-0040",
          code: -32602);
  static Web3RequestException invalidBase58(String parameterName) =>
      Web3RequestException(
          message:
              "Invalid method parameters. Invalid base58 string for $parameterName.",
          walletCode: "WEB3-0040",
          code: -32602);
  static Web3RequestException invalidList({String? parameterName}) =>
      Web3RequestException(
          message:
              "Invalid method parameters. Invalid list argument provided${parameterName != null ? ' for $parameterName' : ''}.",
          walletCode: "WEB3-0050",
          code: -32602);
  static Web3RequestException emptyList({String? parameterName, int? length}) =>
      Web3RequestException(
          message:
              "Invalid method parameters. Invalid list argument provided${parameterName != null ? ' for $parameterName' : ''}.",
          walletCode: "WEB3-0050",
          code: -32602);

  static Web3RequestException invalidMap({String? parameterName}) =>
      Web3RequestException(
          message:
              "Invalid method parameters. Invalid map argument provided${parameterName != null ? ' for $parameterName' : ''}.",
          walletCode: "WEB3-0060",
          code: -32602);

  static Web3RequestException invalidNumbers(String parameterName) =>
      Web3RequestException(
          message:
              "Invalid method parameters. Invalid number argument provided for $parameterName",
          walletCode: "WEB3-0070",
          code: -32602);
  static Web3RequestException invalidObjectKeys(
          String parameterName, List<String> keys) =>
      Web3RequestException(
          message:
              "Invalid method parameters. Invalid $parameterName object. The object must contain one of the following keys: ${keys.join(", ")}",
          walletCode: "WEB3-0070",
          code: -32602);

  // Invalid gas data object. The object must contain one of the following keys: Result, Input, or NestedResult
  static const Web3RequestException invalidMethodArgruments =
      Web3RequestException(
          message: "Invalid method parameters.",
          walletCode: "WEB3-0080",
          code: -32602);

  /// eth

  static const Web3RequestException networkDoesNotExists = Web3RequestException(
      message:
          "Invalid method parameters. The specified Network does not exist.",
      walletCode: "WEB3-5080",
      code: -32600);
  static const Web3RequestException ethereumRpcWrongChainId = Web3RequestException(
      message:
          "The provided RPC link returned a different chain ID. Please ensure the RPC URL matches the expected chain ID.",
      walletCode: "WEB3-5090",
      code: -32600);
  static const Web3RequestException disconnectProvider = Web3RequestException(
      message: "The Provider is disconnected.",
      walletCode: "WEB3-5090",
      code: 4900);
  static Web3RequestException invalidParameters(String message) =>
      Web3RequestException(
          message: "Invalid method parameters: $message",
          data: message,
          walletCode: "WEB3-5100",
          code: -32602);

  static Web3RequestException unsuportedfeatures(String message,
          {String? data, Map<String, dynamic>? dataJson}) =>
      Web3RequestException(
          message: "Unsuported features: $message",
          walletCode: "WEB3-4030",
          code: 4200);
  static Web3RequestException excuteTransactionFailed(String error) =>
      Web3RequestException(
          message: "Excute transaction failed: $error",
          walletCode: "WEB3-4030",
          code: -32602);

  static Web3RequestException signingTransactionFailed(String error) =>
      Web3RequestException(
          message: "Signing transaction failed: $error",
          walletCode: "WEB3-4030",
          code: -32602);

  /// fixed
  static Web3RequestException get invalidSignMessageData => invalidParameters(
      "Invalid message bytes. message must be a valid bytes like Uint8Array");
  static Web3RequestException get invalidWalletStandardSignMessage =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid account or message. The parameters must contain both 'account' and 'message' as uint8Array.");
  static Web3RequestException get invalidStringOrBytesParameters =>
      Web3RequestExceptionConst.invalidParameters(
          "The parameters must contain a valid string or Uint8Array.");

  static Web3RequestException get invalidAccountOrTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid account or transaction. The parameters must contain both 'account' and 'transaction' as uint8Array.");
  static Web3RequestException get mismatchAccountAndTransactionChainId =>
      Web3RequestExceptionConst.message(
          "Invalid transaction chain id. Mismatch between account and transaction chain ID.");
  static Web3RequestException get invalidTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid transaction: Failed to parse or validate the transaction parameters.");

  static Web3RequestException get badSignMessage =>
      Web3RequestExceptionConst.message(
          "Invalid sign message data: cannot sign transaction using this request.");

  static Web3RequestException failedToParse(String key) =>
      Web3RequestExceptionConst.message(
          "Invalid method parameters: failed to parse '$key'.");

  static Web3RequestException message(String message, {String? data}) =>
      Web3RequestException(
          message: message, data: data, walletCode: "WEB3-5100", code: -32602);
}
