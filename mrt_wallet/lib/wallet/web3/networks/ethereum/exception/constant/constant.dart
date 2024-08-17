// import 'package:mrt_wallet/wallet/web3/ethereum/exception/exception/exception.dart';
// import 'package:mrt_wallet/wallet/web3/ethereum/methods/methods.dart';
// import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

// class Web3EthereumExceptionConstant {
//   static const Web3ArgsException invalidTypedDataArgruments = Web3ArgsException(
//       "Invalid request argruments: eth_signTypedData params must be a list contains typedData object and signer account.");

//   static const Web3ArgsException invalidSwitchEthereumChainArgruments =
//       Web3ArgsException(
//           "Invalid request argruments: wallet_switchEthereumChain params must be a list contains object witch 'chainId' property and should be a 0x-prefixed hexadecimal string. ");

//   static const Web3ArgsException invalidTransactionArgruments = Web3ArgsException(
//       "Invalid request argruments: eth_sendTransaction params must be a list contains a valid transaction object.");

//   static const Web3ArgsException invalidTransactionObjectArgrument =
//       Web3ArgsException(
//           "Invalid transaction param: the param must be a valid ethereum transaction object contains to ,from, value and etc.");

//   static const Web3ArgsException invalidTypedDataArgrument = Web3ArgsException(
//       "Invalid typedData param: the param must be list for legacy or object for V3, v4");

//   static const Web3ArgsException invalidPersonalSignArgruments = Web3ArgsException(
//       "Invalid request argruments: personal_sign params must be a list contains data as hex and signer address.");

//   static const Web3ArgsException ethereumChainDoesNotExist = Web3ArgsException(
//       "The specified chain does not exist. Please use 'wallet_addEthereumChain' to add the chain to your wallet.");

//   static const Web3ArgsException invalidAddEthereumChain = Web3ArgsException(
//       "Invalid request argruments: wallet_addEthereumChain params must be a list contains oen object.");

//   static const Web3ArgsException invalidEthereumDecimals = Web3ArgsException(
//       "Invalid decimals param: Ethereum decimals must be exactly 18.");

//   static const Web3ArgsException chainAlreadyExist =
//       Web3ArgsException("The specified chain already exists exist.");

//   static const Web3ArgsException invalidAddEthereumChainRpcUrl = Web3ArgsException(
//       "You must add at least one correct RPC URL with a valid wss, ws, http, or https scheme.");

//   /// The RPC URLs return different chain IDs.
//   static const Web3ArgsException invalidAddEthereumChainRpcChainId =
//       Web3ArgsException("The RPC URLs return different chain IDs.");

//   /// Cannot establish a connection to the provided RPC URLs.
//   static const Web3ArgsException addEthereumChainRpcConnectionFailed =
//       Web3ArgsException(
//           "Cannot establish a connection to the provided RPC URLs.");
//   static Web3EthereumRequestException invalidArgrument<T>(
//           {required String key,
//           Web3EthereumRequestMethods? method,
//           int? code,
//           Map<String, String>? info,
//           String? request}) =>
//       Web3EthereumRequestException(
//           message: "Invalid argrument $key",
//           method: method,
//           code: code,
//           info: info,
//           request: request);
//   static Web3EthereumRequestException message(
//           {required String message,
//           Web3EthereumRequestMethods? method,
//           int? code,
//           Map<String, String>? info,
//           String? request}) =>
//       Web3EthereumRequestException(
//           message: message,
//           method: method,
//           code: code,
//           info: info,
//           request: request);

//   static Web3EthereumRequestException missingArgrument<T>(
//           {required String key,
//           Web3EthereumRequestMethods? method,
//           int? code,
//           Map<String, String>? info,
//           String? request}) =>
//       Web3EthereumRequestException(
//           message: "Missing argrument $key",
//           method: method,
//           code: code,
//           info: info,
//           request: request);

//   static const Web3EthereumRequestException methodNotFound =
//       Web3EthereumRequestException(message: "method_not_found");
// }
