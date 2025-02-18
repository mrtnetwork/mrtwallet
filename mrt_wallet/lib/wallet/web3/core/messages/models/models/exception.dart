import 'package:blockchain_utils/cbor/cbor.dart';

import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message_types.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';

class Web3ExceptionMessage extends Web3MessageCore {
  final String message;
  final int code;
  final String walletCode;
  final String? data;
  final Web3APPData? authenticated;

  Web3ExceptionMessage(
      {required this.message,
      required this.code,
      required this.walletCode,
      this.data,
      this.authenticated});

  factory Web3ExceptionMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: Web3MessageTypes.error.tag);
    return Web3ExceptionMessage(
        message: values.elementAt(0),
        code: values.elementAt(1),
        walletCode: values.elementAt(2),
        data: values.elementAt(3),
        authenticated: values.elemetMybeAs<Web3APPData, CborObject>(4, (p0) {
          return Web3APPData.deserialize(object: p0);
        }));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [message, code, walletCode, data, authenticated?.toCbor()]),
        type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "code": code,
      "walletCode": walletCode,
      "data": data,
    }..removeWhere((k, v) => v == null);
  }

  @override
  Web3MessageTypes get type => Web3MessageTypes.error;

  bool get isAuthenticatedError {
    return code == Web3RequestExceptionConst.missingPermission.code ||
        code == Web3RequestExceptionConst.bannedHost.code;
  }
}
