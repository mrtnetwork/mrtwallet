import 'dart:js_interop';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/app/utils/list/extention.dart';
import 'package:mrt_wallet/app/utils/numbers/numbers.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
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
      JSFunction? enable}) {
    final eip = EIP1193(JSObject());
    eip.request = request;
    eip.on = on;
    eip.removeListener = removeListener;
    eip.providerInfo = EIP6963ProviderInfo.providerInfo;

    if (enable != null) {
      eip.enable = enable;
    }
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
  external factory EthereumRequestParams({String? method, JSAny? params});
  external String get method;
  external set method(String? method);
  external JSAny? get params;
}

class ClientMessageEthereum extends PageMessage {
  const ClientMessageEthereum({required super.method, required super.params});
  factory ClientMessageEthereum.event(EthereumEventTypes event) {
    return ClientMessageEthereum(method: event.name, params: null);
  }
  @override
  JSClientType get type => JSClientType.ethereum;

  factory ClientMessageEthereum.deserialize(
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, tags: JSClientType.ethereum.tag, object: object);
    final params = StringUtils.toJson(values.elementAt(1));
    return ClientMessageEthereum(
        method: values.elementAt(0), params: params["result"]);
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method,
          StringUtils.fromJson({"result": params})
        ]),
        type.tag);
  }
}

enum EthereumEventTypes {
  accountsChanged([100]),
  chainChanged([101]),
  message([102]),
  connect([103]),
  disconnect([104]),
  active([105]),
  disable([106]);

  final List<int> tag;
  const EthereumEventTypes(this.tag);
  static EthereumEventTypes fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static EthereumEventTypes? fromName(String? name) {
    try {
      return values.firstWhere((e) => e.name == name,
          orElse: () => throw Web3RequestExceptionConst.internalError);
    } catch (e) {
      return null;
    }
  }
}

class JSWalletMessageResponseEthereum extends JSWalletNetworkEvent {
  JSWalletMessageResponseEthereum({
    required this.event,
    required super.data,
  }) : super(client: JSClientType.ethereum);
  final EthereumEventTypes event;
  factory JSWalletMessageResponseEthereum.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: JSWalletMessageType.event.tag);
    final client = JSClientType.fromTag(values.elementAt(0));
    if (client != JSClientType.ethereum) {
      throw Web3RequestExceptionConst.internalError;
    }
    return JSWalletMessageResponseEthereum(
        event: EthereumEventTypes.fromTag(values.elementAt(1)),
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
    return "ProviderConnectInfo${toJson()}";
  }
}
