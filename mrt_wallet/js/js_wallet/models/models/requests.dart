import 'dart:js_interop';

import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';

import '../../js_wallet.dart';

enum JSWalletMessageType {
  response([100]),
  event([101]);

  final List<int> tag;
  const JSWalletMessageType(this.tag);

  static JSWalletMessageType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static JSWalletMessageType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

extension type WalletResponse._(JSObject object) implements JSAny {
  external String get id;
  external JSAny? get result;
  external JSWalletError? get error;
}
extension type WalletResponseSuccess._(JSObject object)
    implements WalletResponse {
  external String get id;
  external JSAny? get result;
  external factory WalletResponseSuccess(
      {required String id, required JSAny? result});
}
extension type WalletResponseError._(JSObject object)
    implements WalletResponse {
  external String get id;
  external JSWalletError get error;
  external factory WalletResponseError(
      {required String id, required JSWalletError error});
}

extension type WalletMessage._(JSObject object) implements JSAny {
  external String get requestId;
  external String get id;
  external String get client;
  external WalletMessageData get data;
  JSClientType get clientType => JSClientType.fromName(client);
  external factory WalletMessage(
      {required String requestId,
      required String id,
      required String client,
      required WalletMessageData data});
  factory WalletMessage.response(
      {required String requestId,
      String? id,
      required JSClientType client,
      required WalletMessageResponse data}) {
    return WalletMessage(
        requestId: requestId, id: id ?? "", client: client.name, data: data);
  }
  factory WalletMessage.event(
      {String? requestId,
      String? id,
      required JSClientType client,
      required WalletMessageEvent data}) {
    return WalletMessage(
        requestId: requestId ?? "",
        id: id ?? "",
        client: client.name,
        data: data);
  }
}

extension type WalletMessageData._(JSObject object) implements JSAny {
  external String get type;
  external JSAny? get data;
  JSWalletMessageType get messageType => JSWalletMessageType.fromName(type);
  String asString<T>() {
    return data?.dartify() as String;
  }

  Map<String, dynamic> _convertMap(Map map) {
    map.forEach((key, value) {
      if (value is Map) {
        map[key] = _convertMap(value);
      }
    });
    return Map<String, dynamic>.from(map);
  }

  Map<String, dynamic> asMap() {
    return _convertMap(data?.dartify() as Map);
  }
}

extension type WalletMessageResponse._(JSObject object)
    implements WalletMessageData {
  external factory WalletMessageResponse(
      {required String type, required String status, required JSAny? data});
  external String get type;
  external String get status;
  JSWalletResponseType get statusType => JSWalletResponseType.fromName(status);
  factory WalletMessageResponse.success(JSAny? data) {
    return WalletMessageResponse(
        type: JSWalletMessageType.response.name,
        data: data,
        status: JSWalletResponseType.success.name);
  }
  factory WalletMessageResponse.fail(JSAny? data) {
    return WalletMessageResponse(
        type: JSWalletMessageType.response.name,
        data: data,
        status: JSWalletResponseType.failed.name);
  }
}
extension type WalletMessageEvent._(JSObject object)
    implements WalletMessageData {
  external factory WalletMessageEvent(
      {required String type, required String event, required JSAny? data});
  factory WalletMessageEvent.build({required JSEventType event, Object? data}) {
    return WalletMessageEvent(
        type: JSWalletMessageType.event.name,
        data: data?.jsify(),
        event: event.name);
  }
  external String get type;
  external String get event;
  external JSAny? get data;
  JSEventType get eventType => JSEventType.name(event);
}

enum JSEventType {
  accountsChanged([110]),
  chainChanged([111]),
  message([112]),
  connect([113]),
  disconnect([114]),
  active([115]),
  disable([116]),
  change([117]);

  bool get needEmit =>
      this == accountsChanged || this == chainChanged || this == connect;

  final List<int> tag;
  const JSEventType(this.tag);
  static JSEventType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static JSEventType name(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static JSEventType? fromName(String? name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }
}

enum JSWalletResponseType {
  success([130]),
  failed([131]);

  final List<int> tag;
  const JSWalletResponseType(this.tag);
  static JSWalletResponseType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static JSWalletResponseType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

enum JSClientType {
  global(tag: [150], networkName: ""),
  ethereum(tag: [151], networkName: "Ethereum"),
  tron(tag: [152], networkName: "Tron"),
  solana(tag: [153], networkName: "Solana"),
  ton(tag: [154], networkName: "TON"),
  stellar(tag: [155], networkName: "Stellar"),
  substrate(tag: [156], networkName: "Substrate"),
  aptos(tag: [157], networkName: "Aptos"),
  sui(tag: [158], networkName: "Sui");

  final List<int> tag;
  final String networkName;
  const JSClientType({required this.tag, required this.networkName});

  static JSClientType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static JSClientType fronNetworkName(String? name) {
    // if (name == null) return JSClientType.global;
    return values.firstWhere((e) => e.networkName == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static JSClientType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

extension type PageMessage._(JSObject object) implements JSAny {
  external String get id;
  external String get client;
  external PageMessageData get data;
  JSClientType get clientType => JSClientType.fromName(client);
  external factory PageMessage(
      {required String id,
      required String client,
      required PageMessageData data});
  factory PageMessage.request(
      {String? id,
      required JSClientType client,
      required PageMessageRequest data}) {
    return PageMessage(id: id ?? "", client: client.name, data: data);
  }
  factory PageMessage.event(
      {String? requestId,
      String? id,
      required JSClientType client,
      required PageMessageEvent data}) {
    return PageMessage(id: id ?? "", client: client.name, data: data);
  }
}

enum PageMessageType {
  request([170]),
  event([171]);

  const PageMessageType(this.tags);
  final List<int> tags;

  static PageMessageType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tags, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static PageMessageType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

@JS("PageMessageRequest")
extension type PageMessageData._(JSObject object) implements JSAny {
  external String get type;
  PageMessageType get messageType => PageMessageType.fromName(type);
  // T cast<T extends JSAny>() {
  //   final JSAny? value = this;
  //   print(value.isA<Web3JSRequestParams>());
  //   if (this is! T) {
  //     throw Web3RequestExceptionConst.internalError;
  //   }
  //   return this as T;
  // }

  PageMessageRequest asRequest() {
    if (type != PageMessageType.request.name) {
      throw Web3RequestExceptionConst.internalError;
    }
    return this as PageMessageRequest;
  }

  PageMessageEvent asEvent() {
    if (type != PageMessageType.event.name) {
      throw Web3RequestExceptionConst.internalError;
    }
    return this as PageMessageEvent;
  }
}

extension JSArrayFuture<T extends JSAny> on JSArray<T?> {
  external T? operator [](int index);
  external int get length;

  E elemetAt<E extends JSAny?>(int index) {
    try {
      // ignore: invalid_runtime_check_with_js_interop_types
      return this[index] as E;
    } catch (_) {
      return null as E;
    }
  }
}

@JS("Web3JSRequestParams")
extension type Web3JSRequestParams._(JSObject o) implements JSAny {
  external String get method;
  external String? get id;
  external JSArray<JSAny?>? get params;
  external factory Web3JSRequestParams(
      {String? method, JSArray<JSAny?>? params, int? id});

  Map<String, dynamic> toJson() {
    return {
      "method": method,
      "params": params == null ? [] : params.dartify(),
      "id": id
    };
  }

  List<Object?> dartParams() {
    try {
      return List<Object?>.from(params.dartify() as List);
    } catch (e) {
      return [];
    }
  }

  T? getElemet<T extends JSAny>(int index) {
    try {
      return params![index] as T;
    } catch (_) {
      return null;
    }
  }
}

enum PageRequestType {
  wallet,
  network;

  bool get isNetworkRequest => this == network;
}

@JS("PageMessageRequest")
extension type PageMessageRequest._(JSObject object)
    implements PageMessageData {
  external factory PageMessageRequest(
      {required String type,
      required String method,
      required JSArray<JSAny?>? params,
      required String id,
      JSAny? additionalData});
  external String get type;
  external String get method;
  external JSArray<JSAny?>? params;
  external JSAny? additionalData;
  external String get id;
  factory PageMessageRequest.create(
      {JSArray<JSAny?>? params,
      required String method,
      String? id,
      JSAny? additionalData}) {
    return PageMessageRequest(
        id: id ?? "",
        method: method,
        params: params,
        type: PageMessageType.request.name,
        additionalData: additionalData);
  }

  List<Object?> get dartParams =>
      params?.toDart.map((e) => e.dartify()).toList() ?? [];

  List<Object?>? getElements<T>(int length) {
    final toDart = dartParams;
    if (toDart.length >= length) {
      return toDart.sublist(0, length);
    }
    return null;
  }

  List<T>? getJSParamsAs<T extends JSAny>() {
    try {
      return List<T>.from(params!.toDart as List);
    } catch (e) {
      return null;
    }
  }

  T? getElementAt<T extends JSAny?>(int index) {
    try {
      final item = params![index];
      return item as T;
    } catch (_) {
      return null;
    }
  }

  Object? get getFirstParam {
    final toDart = dartParams;
    if (toDart.isEmpty) {
      return null;
    }
    return toDart.first;
  }

  PageRequestType get pageRequestType {
    if (id.isEmpty) return PageRequestType.network;
    return PageRequestType.wallet;
  }
}

extension type PageMessageEvent._(JSObject object) implements PageMessageData {
  external factory PageMessageEvent(
      {required String type, required String event, required JSAny? data});
  factory PageMessageEvent.build({required JSEventType event, Object? data}) {
    return PageMessageEvent(
        type: PageMessageType.event.name,
        data: data?.jsify(),
        event: event.name);
  }
  external String get type;
  external String get event;
  external JSAny? get data;
  JSEventType get eventType => JSEventType.name(event);
}

enum JSWorkerType {
  client,
  wallet,
  error,
  ready,
  active;

  static JSWorkerType fronName(String? name) {
    return values.firstWhere((e) => e.name == name);
  }
}

@JS()
extension type JSWorkerEvent._(JSObject o) implements JSAny {
  factory JSWorkerEvent({required JSWorkerType type, JSAny? data}) {
    return JSWorkerEvent._(JSObject())
      ..type = type.name
      ..data = data;
  }
  external String? get type;
  external JSAny? get data;
  external set type(String? _);
  external set data(JSAny? _);
  JSWorkerType get eventType => JSWorkerType.fronName(type);
}
@JS()
extension type JSWorkerWalletData._(JSObject o) implements JSAny {
  factory JSWorkerWalletData(
      {required String clientId,
      required String requestId,
      required String data,
      required String type}) {
    return JSWorkerWalletData._(JSObject())
      ..data = data
      ..type = type
      ..clientId = clientId
      ..requestId = requestId;
  }
  external String get clientId;
  external String get requestId;
  external String get data;
  external String get type;
  external set clientId(String? _);
  external set requestId(String? _);
  external set data(String? _);
  external set type(String? _);

  Map<String, dynamic> toJson() {
    return {"id": clientId, "requestId": requestId, "data": data, "type": type};
  }
}
