import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message.dart';
import 'package:mrt_wallet/wallet/web3/core/messages/types/message_types.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/models/authenticated.dart';

class Web3WalletResponseMessage extends Web3MessageCore {
  final Web3APPData? authenticated;
  final Object? result;
  final NetworkType network;
  Web3WalletResponseMessage._(
      {this.result, required this.network, required this.authenticated});
  factory Web3WalletResponseMessage({
    Object? result,
    required NetworkType network,
    Web3APPData? authenticated,
  }) {
    return Web3WalletResponseMessage._(
        result: result, authenticated: authenticated, network: network);
  }

  factory Web3WalletResponseMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: hex,
        object: object,
        tags: Web3MessageTypes.walletResponse.tag);
    final Map<String, dynamic> result =
        StringUtils.toJson(values.elementAt<String>(0));
    return Web3WalletResponseMessage._(
        result: result["result"],
        authenticated: values.elemetMybeAs<Web3APPData, CborTagValue>(
            1, (p0) => Web3APPData.deserialize(object: p0)),
        network: NetworkType.fromTag(values.elementAt(2)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          StringUtils.fromJson({"result": result}),
          authenticated?.toCbor(),
          CborBytesValue(network.tag),
        ]),
        type.tag);
  }

  @override
  Web3MessageTypes get type => Web3MessageTypes.walletResponse;

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

  String resultAsString() {
    try {
      return result as String;
    } catch (e) {
      throw Web3RequestExceptionConst.internalError;
    }
  }
}
