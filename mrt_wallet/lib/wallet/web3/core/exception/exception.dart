import 'package:mrt_wallet/app/error/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/models/models/exception.dart';

class Web3RequestException implements Exception {
  final String message;
  final int code;
  final String walletCode;
  final String? data;

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "code": code,
      "walletCode": walletCode,
      "data": data
    };
  }

  const Web3RequestException(
      {required this.message,
      required this.code,
      required this.walletCode,
      this.data});
  Web3ExceptionMessage toResponseMessage(
      {Map<String, dynamic>? request, String? requestId}) {
    return Web3ExceptionMessage(
        message: message, code: code, walletCode: walletCode, data: data);
  }

  @override
  String toString() {
    return message;
  }
}

class Web3RejectException implements AppException {
  const Web3RejectException._();
  static const Web3RejectException instance = Web3RejectException._();

  @override
  final String message = "web3_request_rejected_desc";
}
