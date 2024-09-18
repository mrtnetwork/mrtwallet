import 'package:blockchain_utils/cbor/cbor.dart';

import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message_types.dart';

class Web3ExceptionMessage extends Web3MessageCore {
  final String message;
  final int code;
  final String walletCode;
  final String? data;

  Web3ExceptionMessage(
      {required this.message,
      required this.code,
      required this.walletCode,
      this.data});

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
        data: values.elementAt(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([message, code, walletCode, data]), type.tag);
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
}
