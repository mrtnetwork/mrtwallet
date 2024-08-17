import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';

enum WalletResponseType {
  response([100]),
  event([101]);

  final List<int> tag;
  const WalletResponseType(this.tag);

  static WalletResponseType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

abstract class WalletResponse with CborSerializable {
  abstract final String? requestId;
  final ClientMessageType client;
  WalletResponseType get type;
  final Object? data;
  WalletResponse({required this.data, required this.client});

  String get resultAsJsonString => StringUtils.fromJson({"result": data});

  static T deserialize<T extends WalletResponse>(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue cbor =
        CborSerializable.decode(cborBytes: bytes, hex: hex, object: object);
    final client = WalletResponseType.fromTag(cbor.tags);
    WalletResponse response;
    switch (client) {
      case WalletResponseType.response:
        response = WalletRequestResponse.deserialize(object: cbor);
        break;
      case WalletResponseType.event:
        response = WalletEventResponse.deserialize(object: cbor);
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (response is! T) {
      throw Web3RequestExceptionConst.internalError;
    }
    return response;
  }

  T cast<T extends WalletResponse>() {
    if (this is! T) {
      throw Web3RequestExceptionConst.internalError;
    }
    return this as T;
  }
}

abstract class WalletEventResponse extends WalletResponse {
  @override
  final String? requestId = null;
  WalletEventResponse({required super.data, required super.client});
  @override
  WalletResponseType get type => WalletResponseType.event;

  factory WalletEventResponse.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue cbor =
        CborSerializable.decode(cborBytes: bytes, hex: hex, object: object);
    final CborListValue values = CborSerializable.cborTagValue(
        object: cbor, tags: WalletResponseType.event.tag);
    final client = ClientMessageType.fromTag(values.elementAt(0));
    switch (client) {
      case ClientMessageType.ethereum:
        return WalletEthereumEventResponse.deserialize(object: cbor);
      default:
    }
    throw Web3RequestExceptionConst.internalError;
  }
}

enum EthereumEvnetTypes {
  accountsChanged([100]),
  chainChanged([101]),
  message([102]),
  connect([103]),
  disconnect([104]),
  active([105]),
  disable([106]);

  final List<int> tag;
  const EthereumEvnetTypes(this.tag);
  static EthereumEvnetTypes fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static EthereumEvnetTypes? fromName(String? name) {
    try {
      return values.firstWhere((e) => e.name == name,
          orElse: () => throw Web3RequestExceptionConst.internalError);
    } catch (e) {
      return null;
    }
  }
}

class WalletEthereumEventResponse extends WalletEventResponse {
  WalletEthereumEventResponse({
    required this.event,
    required super.data,
  }) : super(client: ClientMessageType.ethereum);
  final EthereumEvnetTypes event;
  factory WalletEthereumEventResponse.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletResponseType.event.tag);
    final client = ClientMessageType.fromTag(values.elementAt(0));
    if (client != ClientMessageType.ethereum) {
      throw Web3RequestExceptionConst.internalError;
    }
    return WalletEthereumEventResponse(
        event: EthereumEvnetTypes.fromTag(values.elementAt(1)),
        data: StringUtils.toJson(values.elementAt<String>(2))["result"]);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(client.tag),
          CborBytesValue(event.tag),
          resultAsJsonString
        ]),
        type.tag);
  }
}

enum WalletRequestResponseType {
  success([50]),
  failed([51]);

  final List<int> tag;
  const WalletRequestResponseType(this.tag);
  static WalletRequestResponseType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

class WalletRequestResponse extends WalletResponse {
  @override
  final String requestId;
  final WalletRequestResponseType status;

  WalletRequestResponse(
      {required this.requestId,
      required super.data,
      required super.client,
      required this.status});

  factory WalletRequestResponse.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletResponseType.response.tag);
    return WalletRequestResponse(
        client: ClientMessageType.fromTag(values.elementAt(0)),
        requestId: values.elementAt(1),
        data: StringUtils.toJson(values.elementAt<String>(2))["result"],
        status: WalletRequestResponseType.fromTag(values.elementAt(3)));
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
  WalletResponseType get type => WalletResponseType.response;
}

enum ClientMessageType {
  global([110]),
  ethereum([111]);

  final List<int> tag;
  const ClientMessageType(this.tag);

  static ClientMessageType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

abstract class ClientRequest {
  abstract final String method;
  abstract final String id;
  abstract final ClientMessageType type;
  // Map<String, dynamic> toJson();
  CborTagValue toCbor();
}

class ClientEthereumRequest implements ClientRequest {
  @override
  final String method;
  final dynamic params;
  @override
  final String id;
  const ClientEthereumRequest(
      {required this.method, required this.params, required this.id});
  factory ClientEthereumRequest.event(
      {required EthereumEvnetTypes event, required String requestId}) {
    return ClientEthereumRequest(
        method: event.name, params: null, id: requestId);
  }
  @override
  ClientMessageType get type => ClientMessageType.ethereum;

  List<T>? paramsAsList<T>({int? length}) {
    try {
      final listParam = List<T>.from(params);
      if (length != null && listParam.length < length) {
        return null;
      }
      return listParam;
    } catch (e) {
      return null;
    }
  }

  factory ClientEthereumRequest.deserialize(List<int> bytes) {
    final CborTagValue object = CborObject.fromCbor(bytes) as CborTagValue;
    final CborListValue values = object.value as CborListValue;
    final params = StringUtils.toJson(values.elementAt(1));
    return ClientEthereumRequest(
        method: values.elementAt(0),
        params: params["result"],
        id: values.elementAt(2));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method,
          StringUtils.fromJson({"result": params}),
          id,
        ]),
        [100, 101]);
  }
}
