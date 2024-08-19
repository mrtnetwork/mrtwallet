import 'dart:js_interop';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import '../../../constant/constant.dart';
import '../../models.dart';

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
    final eth = MRTJsObject.freeze(eip);

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
      uuid: JSWalletConstant.uuid,
      name: JSWalletConstant.name,
      icon: JSWalletConstant.mrtPngBase64,
      rdns: JSWalletConstant.rdns);
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
            detail: MRTJsObject.freeze(EIP6963ProviderDetail(
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

  ClientMessageEthereum? toWalletRequest(String requestId) {
    try {
      return ClientMessageEthereum(
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

class ClientMessageEthereum implements ClientMessage {
  @override
  final String method;
  final dynamic params;
  @override
  final String id;
  const ClientMessageEthereum(
      {required this.method, required this.params, required this.id});
  factory ClientMessageEthereum.event(
      {required EthereumEvnetTypes event, required String requestId}) {
    return ClientMessageEthereum(
        method: event.name, params: null, id: requestId);
  }
  @override
  JSClientType get type => JSClientType.ethereum;

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

  factory ClientMessageEthereum.deserialize(List<int> bytes) {
    final CborTagValue object = CborObject.fromCbor(bytes) as CborTagValue;
    final CborListValue values = object.value as CborListValue;
    final params = StringUtils.toJson(values.elementAt(1));
    return ClientMessageEthereum(
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

class JSWalletMessageResponseEthereum extends JSWalletNetworkEvent {
  JSWalletMessageResponseEthereum({
    required this.event,
    required super.data,
  }) : super(client: JSClientType.ethereum);
  final EthereumEvnetTypes event;
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
