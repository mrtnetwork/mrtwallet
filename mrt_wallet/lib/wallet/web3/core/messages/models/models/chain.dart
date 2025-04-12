import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message_types.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';

class Web3ChainMessage extends Web3MessageCore {
  @override
  final Web3MessageTypes type;
  final Web3APPData authenticated;

  Web3ChainMessage({required this.type, required this.authenticated});
  factory Web3ChainMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, object: object, hex: hex);
    final type = Web3MessageTypes.fromTag(tag.tags);
    final values = tag.getList;
    return Web3ChainMessage(
        type: type,
        authenticated: Web3APPData.deserialize(object: values.getCborTag(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([authenticated.toCbor()]), type.tag);
  }
}
