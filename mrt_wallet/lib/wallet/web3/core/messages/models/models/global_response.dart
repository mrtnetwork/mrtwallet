import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message_types.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';

class Web3GlobalResponseMessage extends Web3MessageCore {
  final Web3APPData? authenticated;
  Web3GlobalResponseMessage({this.authenticated});

  factory Web3GlobalResponseMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: Web3MessageTypes.globalResponse.tag);

    return Web3GlobalResponseMessage(
        authenticated: values.elemetMybeAs<Web3APPData, CborTagValue>(
            0, (e) => Web3APPData.deserialize(object: e)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([authenticated?.toCbor()]), type.tag);
  }

  @override
  Web3MessageTypes get type => Web3MessageTypes.globalResponse;
}
