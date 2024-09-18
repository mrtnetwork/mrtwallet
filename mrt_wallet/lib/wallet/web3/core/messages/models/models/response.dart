import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message_types.dart';

class Web3ResponseMessage extends Web3MessageCore {
  final Object? result;
  final NetworkType network;
  Web3ResponseMessage({required this.result, required this.network});

  factory Web3ResponseMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: Web3MessageTypes.response.tag);
    final Map<String, dynamic> result =
        StringUtils.toJson(values.elementAt<String>(0));
    return Web3ResponseMessage(
        result: result["result"],
        network: NetworkType.fromTag(values.elementAt(1)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          StringUtils.fromJson({"result": result}),
          CborBytesValue(network.tag)
        ]),
        type.tag);
  }

  @override
  Web3MessageTypes get type => Web3MessageTypes.response;

  List<T> resultAsList<T>({int? length}) {
    try {
      final list = (result as List).cast<T>();
      if (length == null) return list;
      return list.sublist(0, length);
    } catch (e) {
      throw Web3RequestExceptionConst.internalError;
    }
  }

  Map<String, dynamic> resultAsMap() {
    try {
      return (result as Map).cast<String, dynamic>();
    } catch (e) {
      throw Web3RequestExceptionConst.internalError;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {"type": type.name, "result": result, "network": network.name};
  }
}
