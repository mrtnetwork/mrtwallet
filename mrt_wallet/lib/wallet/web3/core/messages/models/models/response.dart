import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message_types.dart';

class Web3ResponseMessage extends Web3MessageCore {
  final Object? result;
  Web3ResponseMessage(this.result);

  factory Web3ResponseMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: Web3MessageTypes.response.tag);
    final Map<String, dynamic> result =
        StringUtils.toJson(values.elementAt<String>(0));
    return Web3ResponseMessage(result["result"]);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          StringUtils.fromJson({"result": result})
        ]),
        type.tag);
  }

  @override
  Web3MessageTypes get type => Web3MessageTypes.response;
}
