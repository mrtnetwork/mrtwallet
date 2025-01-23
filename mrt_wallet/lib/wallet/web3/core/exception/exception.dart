import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/models/models/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';

class Web3RequestException with Equatable implements Exception {
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
      {Map<String, dynamic>? request,
      String? requestId,
      Web3APPData? authenticated}) {
    return Web3ExceptionMessage(
        message: message,
        code: code,
        walletCode: walletCode,
        data: data,
        authenticated: authenticated);
  }

  @override
  String toString() {
    return message;
  }

  @override
  List get variabels => [code, message];
}

class Web3RejectException implements AppException {
  const Web3RejectException._();
  static const Web3RejectException instance = Web3RejectException._();

  @override
  final String message = "web3_request_rejected_desc";
}
