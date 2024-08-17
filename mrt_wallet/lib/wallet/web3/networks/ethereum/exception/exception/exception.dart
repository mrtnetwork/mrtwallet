// import 'package:mrt_wallet/wallet/web3/ethereum/methods/methods.dart';
// import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';
// import 'package:mrt_wallet/wallet/web3/core/messages/models/models/exception.dart';
// import 'package:mrt_wallet/wroker/models/networks.dart';

// class Web3EthereumRequestException extends Web3RequestException {
//   const Web3EthereumRequestException({
//     required super.message,
//     super.code,
//     super.request,
//     this.method,
//     this.info,
//   });

//   @override
//   final Map<String, String>? info;
//   @override
//   final Web3EthereumRequestMethods? method;
//   @override
//   NetworkType get network => NetworkType.ethereum;

//   @override
//   Web3ExceptionMessage toMessge(
//       {String? newMessage,
//       Map<String, String>? newInfo,
//       String? newRequest,
//       String? requestId}) {
//     return Web3ExceptionMessage(
//         message: newMessage ?? message,
//         code: code ?? -1,
//         info: newInfo ?? info,
//         request: newRequest,
//         requestId: requestId);
//   }
// }
