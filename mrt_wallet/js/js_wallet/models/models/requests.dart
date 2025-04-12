import 'dart:js_interop';

import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';

enum JSWalletMessageType {
  response,
  event;

  static JSWalletMessageType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

enum JSNetworkEventType {
  networkAccountsChanged,
  change,
  defaultChainChanged,
  defaultAccountChanged,
  message;

  static JSNetworkEventType name(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static JSNetworkEventType? fromName(String? name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }
}

enum JSEventType {
  accountsChanged,
  chainChanged,
  message,
  connect,
  disconnect,
  change;

  bool get needEmit =>
      this == accountsChanged ||
      this == chainChanged ||
      this == connect ||
      this == change;

  static JSEventType name(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static JSEventType? fromName(String? name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }
}

enum JSWalletResponseType {
  success,
  failed;

  static JSWalletResponseType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

enum JSClientType {
  global(networkName: ""),
  ethereum(networkName: "Ethereum"),
  tron(networkName: "Tron"),
  solana(networkName: "Solana"),
  ton(networkName: "TON"),
  stellar(networkName: "Stellar"),
  substrate(networkName: "Substrate"),
  aptos(networkName: "Aptos"),
  sui(networkName: "Sui"),
  bitcoin(networkName: "Bitcoin"),
  cosmos(networkName: "Cosmos");

  final String networkName;
  const JSClientType({required this.networkName});

  static JSClientType fronNetworkName(String? name) {
    return values.firstWhere((e) => e.networkName == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static JSClientType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

enum PageMessageType {
  request,
  event;

  static PageMessageType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

enum PageRequestType {
  walletStandard,
  eip1993;

  static PageRequestType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }
}

@JS()
extension type WalletMessage._(JSObject object) implements JSAny {
  external String get requestId;
  external String? get client;
  external WalletMessageData get data;
  JSClientType? get clientType =>
      client == null ? null : JSClientType.fromName(client);
  external factory WalletMessage(
      {required String requestId,
      required String? client,
      required WalletMessageData data});
  factory WalletMessage.response(
      {required String requestId,
      required JSClientType? client,
      required WalletMessageResponse data}) {
    return WalletMessage(
        requestId: requestId, client: client?.name, data: data);
  }
  factory WalletMessage.event(
      {JSClientType? client, required WalletMessageEvent data}) {
    return WalletMessage(requestId: 'event', client: client?.name, data: data);
  }
}
@JS()
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
@JS()
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
@JS()
extension type WalletMessageEvent._(JSObject object)
    implements WalletMessageData {
  external factory WalletMessageEvent(
      {required String type, required JSAny? data});
  factory WalletMessageEvent.build({JSAny? data}) {
    return WalletMessageEvent(type: JSWalletMessageType.event.name, data: data);
  }
  external String get type;
  external String get event;
  external JSAny? get data;
}

@JS()
extension type PageMessage._(JSObject object) implements JSAny {
  external String get requestId;
  external String? get client;
  external PageMessageData get data;
  JSClientType? get clientType =>
      client == null ? null : JSClientType.fromName(client);
  external factory PageMessage(
      {required PageMessageData data,
      required String requestId,
      String? client});
  factory PageMessage.request(
      {required String requestId,
      JSClientType? client,
      required PageMessageRequest data}) {
    return PageMessage(requestId: requestId, client: client?.name, data: data);
  }
  factory PageMessage.event(
      {JSClientType? client, required PageMessageEvent data}) {
    return PageMessage(requestId: 'event', client: client?.name, data: data);
  }
}

@JS()
extension type PageMessageData._(JSObject object) implements JSAny {
  external String get type;
  external String get providerType;
  PageMessageType get messageType => PageMessageType.fromName(type);
  PageRequestType get provider => PageRequestType.fromName(providerType);
  bool get isWalletStandard => provider == PageRequestType.walletStandard;
  bool get isEIP => provider == PageRequestType.eip1993;

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

@JS()
extension type Web3JSRequestParams._(JSObject o) implements JSAny {
  external String get method;
  external String? get id;
  external JSArray<JSAny?>? get params;
  external factory Web3JSRequestParams(
      {String? method, JSArray<JSAny?>? params, int? id});
}

@JS()
extension type PageMessageRequest._(JSObject object)
    implements PageMessageData {
  external String get type;
  external String get method;
  external JSArray<JSAny?>? params;
  external JSAny? additionalData;

  external factory PageMessageRequest({
    required String type,
    required String method,
    required JSArray<JSAny?>? params,
    required String providerType,
  });

  factory PageMessageRequest.create({
    required String method,
    JSArray<JSAny?>? params,
    PageRequestType provider = PageRequestType.walletStandard,
  }) {
    return PageMessageRequest(
        method: method,
        params: params,
        type: PageMessageType.request.name,
        providerType: provider.name);
  }

  List<Object?> get dartParams =>
      params?.toDart.map((e) => e.dartify()).toList() ?? [];

  T? getElementAt<T extends JSAny?>(int index) {
    try {
      final item = params![index];
      return item as T;
    } catch (_) {
      return null;
    }
  }

  T? elementAs<T extends JSAny>(
    int index, {
    List<String> peroperties = const [],
  }) {
    try {
      final item = params![index];
      return MRTJsObject.as<T>(object: item, keys: peroperties);
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
}
@JS()
extension type PageMessageEvent._(JSObject object) implements PageMessageData {
  external factory PageMessageEvent(
      {required String type,
      required String event,
      required JSAny? data,
      required String providerType});
  factory PageMessageEvent.build(
      {required JSEventType event,
      PageRequestType provider = PageRequestType.walletStandard,
      Object? data}) {
    return PageMessageEvent(
        type: PageMessageType.event.name,
        providerType: provider.name,
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
