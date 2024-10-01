import 'package:blockchain_utils/exception/rpc_error.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3RequestExceptionConst {
  static const String requestTimeoutMessage = "Request timeout";
  static const String invalidTransactionTypeMessage =
      "Invalid Transaction type.";
  static const String invalidTransactionTypeOrGas =
      "The provided transaction type does not correspond with the specified gas parameters.";
  static const String eip1559NotSupported =
      "The current network does not support EIP-1559 transactions.";
  static Web3RequestException get invalidSignMessageData => invalidParameters(
      "Invalid message bytes. message must be a valid bytes like Uint8Array");
  static Web3RequestException fromException(Object exception) {
    if (exception is RPCError) {
      return Web3RequestException(
          message: exception.message,
          code: exception.errorCode ?? -1,
          walletCode: "WALLET-001",
          data: StringUtils.tryFromJson(exception.details));
    } else if (exception is ApiProviderException) {
      return Web3RequestException(
          message: "The Provider is disconnected.",
          code: 4901,
          walletCode: "WALLET-001",
          data: exception.isTimeout ? requestTimeoutMessage : null);
    }
    return internalError;
  }

  static const Web3RequestException internalError = Web3RequestException(
      message: "An error occurred during the request",
      walletCode: "WALLET-000",
      code: -32603);
  static const Web3RequestException networkNotSupported = Web3RequestException(
      message: "The wallet does not support the selected network.",
      walletCode: "WALLET-1000",
      code: -32600);
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

  /// The URL is banned by the owner of the wallet. Please use an allowed URL or contact the wallet owner for further assistance.
  /// global
  ///
  static const Web3RequestException wrongRpcUrls = Web3RequestException(
      message: "Invalid method parameters.",
      data:
          "Invalid RPC URL: RPC URLs must be valid and use HTTP, HTTPS, WS, or WSS schemes. Please check the URL and try again.",
      walletCode: "WEB3-0010",
      code: -32602);

  static Web3RequestException invalidStringArgrument(String parameterName) =>
      Web3RequestException(
          message: "Invalid method parameters.",
          data:
              "Invalid string argument provided for $parameterName. Please ensure the input is a valid string and try again.",
          walletCode: "WEB3-0020",
          code: -32602);

  static Web3RequestException invalidAddressArgrument(String addressType) =>
      Web3RequestException(
          message: "Invalid method parameters.",
          data:
              "Invalid address argument provided for $addressType. Please ensure the input is a valid $addressType and try again.",
          walletCode: "WEB3-0030",
          code: -32602);

  static Web3RequestException invalidHexBytes(String parameterName) =>
      Web3RequestException(
          message: "Invalid method parameters.",
          data:
              "Invalid hex string for $parameterName: Hex must be valid, start with '0x', and have an even length. Please check the input and try again.",
          walletCode: "WEB3-0040",
          code: -32602);
  static Web3RequestException invalidBase64Bytes(String parameterName) =>
      Web3RequestException(
          message: "Invalid method parameters.",
          data:
              "Invalid base64 string for $parameterName: Please check the input and try again.",
          walletCode: "WEB3-0040",
          code: -32602);

  static Web3RequestException invalidList({String? parameterName}) =>
      Web3RequestException(
          message: "Invalid method parameters.",
          data:
              "Invalid list argument provided${parameterName != null ? ' for $parameterName' : ''}. Please ensure the input is a valid list and try again.",
          walletCode: "WEB3-0050",
          code: -32602);

  static Web3RequestException invalidMap({String? parameterName}) =>
      Web3RequestException(
          message: "Invalid method parameters.",
          data:
              "Invalid map argument provided${parameterName != null ? ' for $parameterName' : ''}. Please ensure the input is a valid map and try again.",
          walletCode: "WEB3-0060",
          code: -32602);

  static Web3RequestException invalidNumbers(String parameterName) =>
      Web3RequestException(
          message: "Invalid method parameters.",
          data:
              "Invalid number argument provided for $parameterName: Numbers must be valid hexadecimal values starting with '0x'. Please check the input and try again.",
          walletCode: "WEB3-0070",
          code: -32602);
  static Web3RequestException invalidMethodArgruments(String methodName) =>
      Web3RequestException(
          message: "Invalid method parameters.",
          data:
              "Invalid arguments provided for method '$methodName': Please ensure that the arguments for '$methodName' are correct and try again.",
          walletCode: "WEB3-0080",
          code: -32602);
  static const Web3RequestException rpcConnection = Web3RequestException(
      message: "Invalid method parameters.",
      data:
          "RPC connection failed. RPC connection failed. Please ensure the RPC URL is correct and the RPC server is available.",
      walletCode: "WEB3-0100",
      code: -32602);
  static Web3RequestException progressError(String message) =>
      Web3RequestException(
          message: "An error occurred during the request: $message",
          walletCode: "WEB3-0110",
          code: -32603);

  /// eth

  static const Web3RequestException ethWrongDecimal = Web3RequestException(
      message: "Invalid method parameters.",
      data: "Invalid Ethereum decimal. The decimal value must be exactly 18.",
      walletCode: "WEB3-5040",
      code: -32602);
  static const Web3RequestException ethGasArgrument = Web3RequestException(
      message: "Invalid method parameters.",
      data:
          "You cannot use both legacy and EIP-1559 gas parameters simultaneously.",
      walletCode: "WEB3-5050",
      code: -32602);
  static const Web3RequestException ethGasArgrument2 = Web3RequestException(
      message: "Invalid method parameters.",
      data:
          "To use EIP-1559 gas metrics, you must fill both maxFeePerGas and maxPriorityFeePerGas fields.",
      walletCode: "WEB3-5060",
      code: -32602);

  static const Web3RequestException ethTypedData = Web3RequestException(
      message: "Invalid method parameters.",
      data:
          "Invalid typedData parameter: the provided typedData is not valid. Please check the data and try again.",
      walletCode: "WEB3-5070",
      code: -32602);
  static Web3RequestException ethTypedDataMessage(String message) =>
      Web3RequestException(
          message: "Invalid method parameters.",
          data: "Invalid typedData parameter: $message",
          walletCode: "WEB3-5070",
          code: -32602);

  static const Web3RequestException ethereumNetworkDoesNotExist =
      Web3RequestException(
          message: "Invalid method parameters.",
          data:
              "The specified Ethereum network does not exist. Please use 'wallet_addEthereumChain' to add the network before proceeding.",
          walletCode: "WEB3-5080",
          code: -32600);
  static const Web3RequestException ethereumRpcWrongChainId = Web3RequestException(
      message:
          "The provided RPC link returned a different chain ID. Please ensure the RPC URL matches the expected chain ID.",
      walletCode: "WEB3-5090",
      code: -32600);
  static Web3RequestException disconnected({String? message}) =>
      Web3RequestException(
          message: "The Provider is disconnected.",
          walletCode: "WEB3-5090",
          data: message ??
              "The current blockchain network lacks an active provider. Please use 'wallet_addEthereumChain' to add a provider to the network.",
          code: 4900);
  static Web3RequestException invalidParameters(String message) =>
      Web3RequestException(
          message: "Invalid method parameters: $message",
          data: message,
          walletCode: "WEB3-5100",
          code: -32602);
  static Web3RequestException failedRequest(String message,
          {String? data, Map<String, dynamic>? dataJson}) =>
      Web3RequestException(
          message: message,
          data: data ?? StringUtils.tryFromJson(dataJson),
          walletCode: "WEB3-5100",
          code: -32602);
}

/// The Provider is disconnected
