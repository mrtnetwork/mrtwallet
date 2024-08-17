import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message_types.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';

import 'response.dart';

class Web3ChainMessage extends Web3MessageCore {
  final List<int> message;
  @override
  final Web3MessageTypes type;
  final Web3APPAuthentication authenticated;
  final Web3ResponseMessage? response;

  Web3ChainMessage({
    required List<int> message,
    required this.type,
    required this.authenticated,
    this.response,
  }) : message = BytesUtils.toBytes(message, unmodifiable: true);
  factory Web3ChainMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, object: object, hex: hex);
    final type = Web3MessageTypes.fromTag(tag.tags);
    final values = tag.getList;
    final response = values.getCborTag(2);
    return Web3ChainMessage(
        message: values.elementAt(0),
        type: type,
        authenticated:
            Web3APPAuthentication.deserialize(object: values.getCborTag(1)),
        response: response == null
            ? null
            : Web3ResponseMessage.deserialize(object: response));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(message),
          authenticated.toCbor(),
          response?.toCbor()
        ]),
        type.tag);
  }
}
