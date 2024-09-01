import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';

import '../../constant/constant.dart';
import '../../utils/utils/utils.dart';
import 'networks/ethereum.dart';
import 'networks/solana.dart';
import 'networks/tron.dart';

enum JSWalletMessageType {
  response([100]),
  event([101]);

  final List<int> tag;
  const JSWalletMessageType(this.tag);

  static JSWalletMessageType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

abstract class JSWalletMessage with CborSerializable {
  abstract final String? requestId;
  final JSClientType client;
  JSWalletMessageType get type;
  final Object? data;
  JSWalletMessage({required this.data, required this.client});

  String get resultAsJsonString => StringUtils.fromJson({"result": data});

  static T deserialize<T extends JSWalletMessage>(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue cbor =
        CborSerializable.decode(cborBytes: bytes, hex: hex, object: object);
    final client = JSWalletMessageType.fromTag(cbor.tags);
    JSWalletMessage response;
    switch (client) {
      case JSWalletMessageType.response:
        response = JSWalletMessageResponse.deserialize(object: cbor);
        break;
      case JSWalletMessageType.event:
        response = JSWalletNetworkEvent.deserialize(object: cbor);
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (response is! T) {
      throw Web3RequestExceptionConst.internalError;
    }
    return response;
  }

  T cast<T extends JSWalletMessage>() {
    if (this is! T) {
      throw Web3RequestExceptionConst.internalError;
    }
    return this as T;
  }

  T dataAs<T>() {
    return data as T;
  }
}

abstract class JSWalletNetworkEvent extends JSWalletMessage {
  @override
  final String? requestId = null;
  JSWalletNetworkEvent({required super.data, required super.client});
  @override
  JSWalletMessageType get type => JSWalletMessageType.event;

  factory JSWalletNetworkEvent.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue cbor =
        CborSerializable.decode(cborBytes: bytes, hex: hex, object: object);
    final CborListValue values = CborSerializable.cborTagValue(
        object: cbor, tags: JSWalletMessageType.event.tag);
    final client = JSClientType.fromTag(values.elementAt(0));
    switch (client) {
      case JSClientType.ethereum:
        return JSWalletMessageResponseEthereum.deserialize(object: cbor);
      case JSClientType.tron:
        return JSWalletMessageResponseTron.deserialize(object: cbor);
      case JSClientType.solana:
        return JSWalletMessageResponseSolana.deserialize(object: cbor);
      default:
    }
    throw Web3RequestExceptionConst.internalError;
  }
}

enum JSWalletResponseType {
  success([50]),
  failed([51]);

  final List<int> tag;
  const JSWalletResponseType(this.tag);
  static JSWalletResponseType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

class JSWalletMessageResponse extends JSWalletMessage {
  @override
  final String requestId;
  final JSWalletResponseType status;

  JSWalletMessageResponse(
      {required this.requestId,
      required super.data,
      required super.client,
      required this.status});

  factory JSWalletMessageResponse.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: JSWalletMessageType.response.tag);
    return JSWalletMessageResponse(
        client: JSClientType.fromTag(values.elementAt(0)),
        requestId: values.elementAt(1),
        data: StringUtils.toJson(values.elementAt<String>(2))["result"],
        status: JSWalletResponseType.fromTag(values.elementAt(3)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(client.tag),
          requestId,
          resultAsJsonString,
          CborBytesValue(status.tag),
        ]),
        type.tag);
  }

  @override
  JSWalletMessageType get type => JSWalletMessageType.response;
}

enum JSClientType {
  global([110]),
  ethereum([111]),
  tron([112]),
  solana([113]);

  final List<int> tag;
  const JSClientType(this.tag);

  static JSClientType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

class JSPageRequest with CborSerializable {
  JSClientType get type => message.type;
  final String id;
  final PageMessage message;
  const JSPageRequest({required this.message, required this.id});
  factory JSPageRequest.deserialize(
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        hex: cborHex,
        object: object,
        tags: JSWalletConstant.pageRequestTag);
    return JSPageRequest(
        message: PageMessage.deserialize(object: values.getCborTag(0)),
        id: values.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([message.toCbor(), id]),
        JSWalletConstant.pageRequestTag);
  }
}

abstract class PageMessage with CborSerializable {
  final String method;
  abstract final JSClientType type;
  final Object? params;
  const PageMessage({required this.method, required this.params});
  factory PageMessage.deserialize(
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborTagValue tag =
        CborSerializable.decode(cborBytes: bytes, hex: cborHex, object: object);
    final type = JSClientType.fromTag(tag.tags);
    switch (type) {
      case JSClientType.ethereum:
        return ClientMessageEthereum.deserialize(object: tag);
      case JSClientType.tron:
        return ClientMessageTron.deserialize(object: tag);
      case JSClientType.solana:
        return ClientMessageSolana.deserialize(object: tag);
      default:
        throw Web3RequestExceptionConst.internalError;
    }
  }

  List<T>? paramsAsList<T>({int? length}) {
    try {
      final listParam = List<T>.from(params as List);
      if (length != null && listParam.length < length) {
        return null;
      }
      return listParam;
    } catch (e) {
      return null;
    }
  }

  Map<K, V>? paramsAsMap<K, V>() {
    try {
      return JsUtils.toMap<K, V>(params);
    } catch (e) {
      return null;
    }
  }

  T cast<T extends PageMessage>() {
    if (this is! T) {
      throw Web3RequestExceptionConst.internalError;
    }
    return this as T;
  }
}
