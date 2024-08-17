import 'dart:js_interop';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import '../models.dart';

@JS("EIP-1193")
extension type EIP1193(JSObject _) implements MRTJsObject {
  /// The request method is intended as a transport- and protocol-agnostic wrapper function for Remote Procedure Calls (RPCs).
  external set request(JSFunction f);
  @JS("request")
  external JSPromise<JSAny?> requestPromis(EthereumRequestParams params);
  external set on(JSFunction f);
  external set removeListener(JSFunction f);
  external set providerInfo(EIP6963ProviderInfo f);
  external set disconnect(JSFunction f);
  external EIP6963ProviderInfo get providerInfo;
  external set enable(JSFunction f);
  external bool get isMetaMask;
  external set chainId(String? chainId);
  external set networkVersion(String? networkVersion);
  external set selectedAddress(String? selectedAddress);

  static EIP1193 setup(
      {required JSFunction request,
      required JSFunction on,
      required JSFunction removeListener,
      required JSFunction disconnect,
      JSFunction? enable}) {
    final eip = EIP1193(JSObject());
    eip.request = request;
    eip.on = on;
    eip.removeListener = removeListener;
    eip.providerInfo = EIP6963ProviderInfo._providerInfo;

    if (enable != null) {
      eip.enable = enable;
    }
    final eth = JSObjectFreez.freeze(eip);

    return eth;
  }
}
@JS("EIP6963ProviderInfo")
extension type EIP6963ProviderInfo._(JSObject _) implements MRTJsObject {
  external factory EIP6963ProviderInfo(
      {required String uuid,
      required String name,
      required String icon,
      String? rdns});
  external String get uuid;
  external String get name;
  external String get icon;
  external String get rdns;
  static final _providerInfo = EIP6963ProviderInfo(
      uuid: "350670db-19fa-4704-a166-e52e178b59d2",
      name: "MRT",
      icon: "data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg'/>",
      rdns: "com.mrtnetwork.wallet");
}
@JS("EIP6963ProviderDetail")
extension type EIP6963ProviderDetail._(JSObject _) implements MRTJsObject {
  external factory EIP6963ProviderDetail(
      {required EIP6963ProviderInfo info, required EIP1193 provider});
  external EIP6963ProviderInfo get info;
  external EIP1193 get provider;

  static void setup(EIP1193 ethereum) {
    final event = CustomEvent(
        "eip6963:announceProvider",
        EventInit(
            bubbles: true,
            cancelable: false,
            detail: JSObjectFreez.freeze(EIP6963ProviderDetail(
                info: ethereum.providerInfo, provider: ethereum))));
    jsWindow.addEventListener(
        "eip6963:requestProvider",
        (CustomEvent r) {
          jsWindow.dispatchEvent(event);
        }.toJS);
    jsWindow.dispatchEvent(event);
  }
}

@JS("EthereumRequestInterface")
extension type EthereumRequestParams._(JSObject o)
    implements Web3JSRequestParams {
  external factory EthereumRequestParams({String? method, JSAny? params});
  external String? get method;
  external set method(String? method);
  external JSAny? get params;
  external String? get id;
  external set id(String? id);

  ClientEthereumRequest? toWalletRequest(String requestId) {
    try {
      return ClientEthereumRequest(
          method: method!, params: params.dartify(), id: requestId);
    } catch (e) {
      return null;
    }
  }

  bool get isValidRequest => method != null && method!.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {"method": method, "params": params == null ? [] : params.dartify()};
  }

  List<String> toStringListParam({required String methodName, int? length}) {
    final toDart = toListParams(methodName, length: length);
    final toListString =
        MethodUtils.nullOnException(() => List<String>.from(toDart));
    if (toListString == null) {
      throw Web3RequestExceptionConst.invalidList(methodName);
    }
    return toListString;
  }

  List<dynamic>? tryParamsToList({int? length}) {
    try {
      if (params == null) return null;

      final toDart = params.dartify();
      if (toDart == null ||
          toDart is! List ||
          length != null && toDart.length < length) {
        return null;
      }
      return toDart;
    } catch (e) {
      return null;
    }
  }

  List<dynamic> toListParams(String name, {int? length}) {
    final toDart = params?.dartify();
    if (toDart == null || toDart is! List) {
      throw Web3RequestExceptionConst.invalidList(name);
    }
    if (length != null && toDart.length < length) {
      throw Web3RequestExceptionConst.invalidList(name);
    }
    return toDart;
  }
}
@JS("Object")
extension type JSObjectFreez(JSObject _) implements MRTJsObject {
  @JS("freeze")
  external static T freeze<T extends JSObject>(T obj);
  @JS("defineProperty")
  external static void defineProperty(
      JSObject obj, String prop, JSObject descriptor);
  @JS("isFrozen")
  external static bool isFrozen(JSObject obj);
}

class EthereumDisconnectEvent {
  final int code;
  final String reason;
  const EthereumDisconnectEvent(this.code, this.reason);
  factory EthereumDisconnectEvent.fromJson(Map<String, dynamic> json) {
    return EthereumDisconnectEvent(json["code"], json["reason"]);
  }
  Map<String, dynamic> toJson() {
    return {"code": code, "reason": reason};
  }
}
