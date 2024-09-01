import 'dart:js_interop';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/app/utils/list/extention.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'ethereum.dart';
import '../requests.dart';

@JS("tron")
external set tron(Proxy? tron);

class JSTronAddress {
  @JSExport("base58")
  final String base58;
  @JSExport("hex")
  final String hex;
  const JSTronAddress({required this.base58, required this.hex});
  factory JSTronAddress.fromJson(Map<String, dynamic> json) {
    return JSTronAddress(base58: json["base58"], hex: json["hex"]);
  }

  Map<String, dynamic> toJson() {
    return {"base58": base58, "hex": hex};
  }

  @JSExport("toString")
  @override
  String toString() {
    return base58;
  }

  @override
  operator ==(other) {
    if (other is! JSTronAddress) return false;
    return hex == other.hex;
  }

  JSObject get toJS => createJSInteropWrapper(this);

  @override
  int get hashCode => hex.hashCode ^ base58.hashCode;
}

@JS()
extension type TronWebConstroctorOption._(JSAny _) implements JSAny {
  external factory TronWebConstroctorOption(String? fullHost,
      String? solidityNode, String? eventServer, String? privateKey);
}
@JS("TronWeb")
extension type TronWeb._(JSAny _) implements JSAny {
  external factory TronWeb(
      String? solidityNode, String? eventServer, String? privateKey);

  @JS("trx")
  external TronWebTRX get trx;
  @JS("trx")
  external set trxx(Proxy trx);

  external set setSolidityNode(JSFunction setAddress);
  external set setFullNode(JSFunction setPrivateKey);
  external set setAddress(JSFunction setAddress);
  external set setPrivateKey(JSFunction setPrivateKey);
  external set solidityNode(HttpProvider? solidityNode);
  external set fullNode(HttpProvider? fullNode);
  external set setHeader(JSFunction setHeader);
  external set setFullNodeHeader(JSAny? setFullNodeHeader);
  external set setDefaultBlock(JSAny? fullNodsetDefaultBlocke);
  external HttpProvider get solidityNode;
  external HttpProvider get fullNode;
  // external JSAny get pro

  @JS("trx")
  external TronWebTRX? get trxNull;
  external JSObject? get defaultAddress;
  external set defaultAddress(JSObject? defaultAddress);
}
@JS("TronWeb.providers.HttpProvider")
extension type HttpProvider._(JSAny _) implements JSAny {
  external factory HttpProvider(String host);
  external String get host;
}

@JS("TIP-1193")
extension type TIP1193(JSObject _) implements EIP1193 {
  @JS("tronWeb")
  external set tronWeb(Proxy tronWeb);

  external set ready(bool ready);

  static TIP1193 setup(
      {required JSFunction request,
      required JSFunction on,
      required JSFunction removeListener,
      required JSFunction disconnect,
      required Proxy tronWeb,
      JSFunction? enable}) {
    final tip = TIP1193(JSObject());
    tip.request = request;
    tip.on = on;
    tip.removeListener = removeListener;
    tip.tronWeb = tronWeb;
    tip.providerInfo = EIP6963ProviderInfo.providerInfo;
    tip.ready = true;
    if (enable != null) {
      tip.enable = enable;
    }
    final eth = MRTJsObject.freeze(tip);

    return eth;
  }
}
@JS("TronRequestInterface")
extension type TronRequestParams._(JSObject o)
    implements EthereumRequestParams {
  external factory TronRequestParams(
      {String? method, JSAny? params, String? perivateKey});
}

@JS()
extension type TronWebTRX(JSObject _) implements MRTJsObject {
  @JS("sign")
  external set signTransaction__(JSFunction f);

  @JS("multiSign")
  external set multiSignTransaction(JSFunction f);

  @JS("signMessageV2")
  external set signMessageV2__(JSFunction f);
}

enum TronEventTypes {
  accountsChanged([110]),
  chainChanged([111]),
  message([112]),
  connect([113]),
  disconnect([114]),
  active([115]),
  disable([116]);

  final List<int> tag;
  const TronEventTypes(this.tag);
  static TronEventTypes fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw Web3RequestExceptionConst.internalError);
  }

  static TronEventTypes? fromName(String? name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }
}

class ClientMessageTron extends PageMessage {
  const ClientMessageTron({required super.method, required super.params});
  factory ClientMessageTron.event(TronEventTypes event) {
    return ClientMessageTron(method: event.name, params: null);
  }
  @override
  JSClientType get type => JSClientType.tron;

  factory ClientMessageTron.deserialize(
      {List<int>? bytes, String? cborHex, CborObject? object}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        tags: JSClientType.tron.tag,
        hex: cborHex,
        object: object);
    final params = StringUtils.toJson(values.elementAt(1));
    return ClientMessageTron(
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

class TronWebNodeInfo {
  final String solidityNode;
  final String fullNode;
  final String chainId;
  final String? base58;
  final String? hex;
  final String? eventServer;
  const TronWebNodeInfo(
      {required this.solidityNode,
      required this.fullNode,
      required this.chainId,
      this.base58,
      this.hex,
      this.eventServer});
  factory TronWebNodeInfo.fromJson(Map<String, dynamic> json) {
    return TronWebNodeInfo(
        solidityNode: json["solidityNode"],
        fullNode: json["fullNode"],
        chainId: json["chainId"],
        hex: json["hex"],
        base58: json["base58"],
        eventServer: json["eventServer"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "solidityNode": solidityNode,
      "fullNode": fullNode,
      "chainId": chainId,
      "hex": hex,
      "eventServer": eventServer,
      "base58": base58
    };
  }

  JSTronAddress? toAddress() {
    if (base58 == null || hex == null) return null;
    return JSTronAddress(base58: base58!, hex: hex!);
  }

  TronWeb toTronWeb() {
    try {
      final tronWeb = TronWeb(fullNode, fullNode, eventServer);
      final addr = toAddress();
      tronWeb.defaultAddress =
          addr == null ? null : createJSInteropWrapper(addr);
      return tronWeb;
    } catch (e) {
      rethrow;
    }
  }
}

class JSWalletMessageResponseTron extends JSWalletNetworkEvent {
  JSWalletMessageResponseTron({
    required this.event,
    required super.data,
  }) : super(client: JSClientType.tron);
  final TronEventTypes event;
  factory JSWalletMessageResponseTron.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: JSWalletMessageType.event.tag);
    final client = JSClientType.fromTag(values.elementAt(0));
    if (client != JSClientType.tron) {
      throw Web3RequestExceptionConst.internalError;
    }
    return JSWalletMessageResponseTron(
        event: TronEventTypes.fromTag(values.elementAt(1)),
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

class TronAccountsChanged {
  final List<String> accounts;
  final JSTronAddress? defaultAddress;
  TronAccountsChanged(
      {required List<String> accounts, required this.defaultAddress})
      : accounts = accounts.imutable;
  factory TronAccountsChanged.fromJson(Map<String, dynamic> json) {
    return TronAccountsChanged(
        accounts: (json["accounts"] as List).cast(),
        defaultAddress: json["defaultAddress"] == null
            ? null
            : JSTronAddress.fromJson(json["defaultAddress"]));
  }
  Map<String, dynamic> toJson() {
    return {"accounts": accounts, "defaultAddress": defaultAddress?.toJson()};
  }

  JSAny? get toJSEvent => accounts.jsify();

  @JSExport("toString")
  @override
  String toString() {
    return "TronAccountsChanged${toJson()}";
  }
}
