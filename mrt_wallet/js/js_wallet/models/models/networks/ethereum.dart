import 'dart:js_interop';
import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/app/utils/numbers/numbers.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import '../../../constant/constant.dart';
import '../../models.dart';

@JSExport()
class ProxyMethodHandler<T> {
  final T object;
  ProxyMethodHandler(this.object);

  @JSExport("set")
  bool set(JSAny object, JSAny prop, JSAny? value, JSAny? receiver) {
    return false;
  }

  @JSExport("get")
  JSAny? get(JSAny object, JSAny prop) {
    return Reflect.get(object, prop, null);
  }
}

@JS("Reflect")
extension type Reflect._(JSObject _) implements JSAny {
  external factory Reflect();
  @JS("get")
  external static JSAny? get(JSAny? object, JSAny? prob, JSAny? receiver);
  @JS("set")
  external static bool set(
      JSAny? object, JSAny? prob, JSAny? value, JSAny? receiver);
}

@JS("Proxy")
extension type Proxy._(JSObject _) implements JSAny {
  external factory Proxy(JSAny target, JSObject handler);
}

extension type EIP1193(JSObject _) implements MRTNetworkAdapter {
  /// The request method is intended as a transport- and protocol-agnostic wrapper function for Remote Procedure Calls (RPCs).
  external set request(JSFunction f);
  @JS("request")
  external JSPromise<JSAny?> requestPromis(EthereumRequestParams params);
  external set on(JSFunction f);
  external set removeListener(JSFunction f);
  external set disconnect(JSFunction f);

  @JS("chainId")
  external set chainId(String? chainId);
  @JS("chainId")
  external String? get chainId;
  @JS("networkVersion")
  external set networkVersion(String? networkVersion);
  @JS("networkVersion")
  external String? get networkVersion;
  @JS("selectedAddress")
  external set selectedAddress(JSString? selectedAddress);
  @JS("selectedAddress")
  external JSString? get selectedAddress;

  static EIP1193 setup(
      {required JSFunction request,
      required JSFunction on,
      required JSFunction removeListener,
      required JSFunction disconnect,
      required JSFunction cancelAllListener,
      required JSFunction onWalletRequest,
      JSFunction? enable}) {
    final eip = EIP1193(JSObject());
    eip.sendWalletRequest = onWalletRequest;
    eip.cancelListener = removeListener;

    eip.request = request;
    eip.on = on;
    eip.removeListener = removeListener;
    eip.providerInfo = EIP6963ProviderInfo.providerInfo;
    eip.enable = enable;
    eip.cancelAllListener = cancelAllListener;

    return eip;
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
  static final providerInfo = EIP6963ProviderInfo(
      uuid: JSWalletConstant.uuid,
      name: JSWalletConstant.name,
      icon: JSWalletConstant.mrtPngBase64,
      rdns: JSWalletConstant.rdns);
}
@JS("EIP6963ProviderDetail")
extension type EIP6963ProviderDetail._(JSObject _) implements MRTJsObject {
  external factory EIP6963ProviderDetail(
      {required EIP6963ProviderInfo info, required Proxy provider});
  external EIP6963ProviderInfo get info;
  external EIP1193 get provider;

  static void setup(Proxy ethereum) {
    final event = CustomEvent(
        "eip6963:announceProvider",
        EventInit(
            bubbles: true,
            cancelable: false,
            detail: MRTJsObject.freeze(EIP6963ProviderDetail(
                info: EIP6963ProviderInfo.providerInfo, provider: ethereum))));
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
  external factory EthereumRequestParams(
      {String? method, JSAny? params, int? id});
  external String get method;
  external set method(String? method);
  external JSArray<JSAny>? get params;
  Map<String, dynamic> toJson() {
    return {"method": method, "params": params == null ? [] : params.dartify()};
  }
}

class EthereumAccountsChanged {
  final List<String> accounts;
  final String? defaultAddress;
  EthereumAccountsChanged(
      {required List<String> accounts, required this.defaultAddress})
      : accounts = accounts.imutable;
  factory EthereumAccountsChanged.fromJson(Map<String, dynamic> json) {
    return EthereumAccountsChanged(
        accounts: (json["accounts"] as List).cast(),
        defaultAddress: json["defaultAddress"]);
  }
  Map<String, dynamic> toJson() {
    return {"accounts": accounts, "defaultAddress": defaultAddress};
  }

  JSAny? get toJSEvent => accounts.jsify();
  @JSExport("toString")
  @override
  String toString() {
    return "EthereumAccountsChanged${toJson()}";
  }
}

class ProviderConnectInfo {
  @JSExport("chainId")
  final String chainId;
  final BigInt netVersion;
  ProviderConnectInfo(this.netVersion) : chainId = netVersion.toRadix16;
  factory ProviderConnectInfo.fromJson(Map<String, dynamic> json) {
    return ProviderConnectInfo(BigInt.parse(json["net_version"]));
  }
  Map<String, dynamic> toJson() {
    return {"net_version": netVersion.toString()};
  }

  JSAny? get toJSEvent => createJSInteropWrapper(this);
  @JSExport("toString")
  @override
  String toString() {
    return "ProviderConnectInfo${{"chainId": chainId}}";
  }
}
